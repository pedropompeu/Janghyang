"""The porcelain figures of Janghyang (spec §14.1 and §14.4 item 2; plan T37).

The staging figures, Elias's copies and the Gastos all come from one CC0 body
(Human Base Meshes v1.4.1, Blender Studio: `GEO-body_male_realistic`), turned
into a painted porcelain figurine. The clothes are the body itself, pushed out
and smoothed region by region (the mesh's sculpt face sets), so the figure
reads as one glazed piece.

Variants, one skinned .glb each (Y up, facing -Z in Godot, 1.77 m tall like
the blockout mannequin of scripts/mannequin.gd):

  figura_adulto  painted adult: Inácio, Elias and his copies, the shop dummy
  figura_menino  child proportions: the boy of chapters 1 and 2
  gasto          the worn version: no eyes, a smoothed face, long fingers,
                 heavy craquelê

Each variant also gets Janghyang/assets/textures/<variant>.png, a 1K gray map
(ambient occlusion x craquelê) that multiplies the style colors set in Godot.
Material slots: skin, coat, trousers, shoes, hair, eyes, iris.

Bones: hips, spine, chest, head, upper_arm/forearm/hand and thigh/shin/foot
(.L is the figure's left, -X in Godot). The rest pose has the arms hanging.

Run from the repo root:

  blender -b --factory-startup --disable-autoexec \\
      arte/fontes/human-base-meshes/extraido/human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend \\
      --python arte/blender/figuras.py -- [variant ...] [--preview DIR]

With no variant, builds all three. --preview DIR also renders check images.
"""
import math
from collections import defaultdict
import os
import sys

import bmesh
import bpy
from bpy_extras.bmesh_utils import bmesh_linked_uv_islands
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _common as common  # noqa: E402

BODY = "GEO-body_male_realistic"
EYES = (BODY + ".eye.L", BODY + ".eye.R")
HEIGHT = 1.77

# The body's sculpt face sets (attribute `.sculpt_face_set`), one per region.
FS_CHEST, FS_WAIST, FS_PELVIS, FS_HEAD = 1, 19, 18, 17
FS_FACE = (2, 3, 4, 5, 6, 7, 8, 22)
FS_UPPER_ARM, FS_FOREARM, FS_HAND = (20, 21), (11, 12), (9, 10)
FS_THIGH, FS_SHIN, FS_FOOT = (23, 24), (15, 16), (13, 14)
FS_TOES = tuple(range(25, 64))
FS_FINGERS = tuple(range(64, 200))

SIDES = {-1: ".L", 1: ".R"}
SLOTS = ("skin", "coat", "trousers", "shoes", "hair", "eyes", "iris")

# name: face sets (None: the hair, cut from the head), push out (m), smoothing passes
CLOTHES = {
    "coat": ((FS_CHEST, FS_WAIST) + FS_UPPER_ARM + FS_FOREARM, 0.018, 40),
    "trousers": ((FS_PELVIS,) + FS_THIGH + FS_SHIN, 0.010, 30),
    "shoes": (FS_FOOT + FS_TOES, 0.008, 0),
    "hair": (None, 0.011, 12),
}
SLACK = 40  # passes that take the muscles out of the coat
CHILD_FACE = 5  # passes that soften the boy's face
SHOE_RELAX = 150  # passes that spread the shoe over its hull
COLLAR = 0.035  # the coat climbs this far up the neck (m)
HEM = 0.0  # and comes down to the hip joints plus this (m)

ARM_OUT = 6.0  # degrees from vertical, the arms of the rest pose
CHILD = {"head": 1.3, "upper_arm.L": 0.9, "upper_arm.R": 0.9, "thigh.L": 0.86, "thigh.R": 0.86, "chest": 0.94}
FINGERS = 1.6  # how much longer a Gasto's fingers are

VARIANTS = {
    "figura_adulto": {"child": False, "worn": False, "fine": 0.2, "coarse": 0.0},
    "figura_menino": {"child": True, "worn": False, "fine": 0.2, "coarse": 0.0},
    "gasto": {"child": False, "worn": True, "fine": 0.4, "coarse": 0.75},
}

# Only for the preview renders; the game sets its own colors.
PREVIEW = {
    "figura_adulto": {"coat": "#4a5866", "skin": "#d9b99b", "hair": "#4a3a2c", "trousers": "#2b2b30"},
    "figura_menino": {"coat": "#6b5a3e", "skin": "#e0c2a2", "hair": "#5a4430", "trousers": "#3a3f4a"},
    "gasto": {"coat": "#56504a", "skin": "#ece6d8", "hair": "#ece6d8", "trousers": "#38332e"},
}
DEFAULTS = {"shoes": "#1f1b18", "eyes": "#e8e2d4", "iris": "#2e2620"}
ROUGHNESS = {"skin": 0.35, "coat": 0.6, "trousers": 0.6, "shoes": 0.45, "hair": 0.5, "eyes": 0.2, "iris": 0.2}


# --- reading the mesh ------------------------------------------------------

def face_sets(me):
    attr = me.attributes[".sculpt_face_set"]
    return [d.value for d in attr.data]


def verts_by_set(me, fs):
    out = {}
    for p in me.polygons:
        out.setdefault(fs[p.index], set()).update(p.vertices)
    return out


def side_of(me, verts):
    return -1 if sum(me.vertices[i].co.x for i in verts) < 0 else 1


def centroid(me, verts):
    return sum((me.vertices[i].co for i in verts), Vector()) / len(verts)


def joints(me, fs):
    """Joint centers from the rings where two regions meet."""
    vs = verts_by_set(me, fs)

    def group(sets):
        return set().union(*(vs.get(k, set()) for k in sets))

    def ring(a, b):
        shared = group(a) & group(b)
        assert shared, "no ring between %s and %s" % (a, b)
        return centroid(me, shared)

    j = {
        "neck": ring((FS_CHEST,), (FS_HEAD,)),
        "waist": ring((FS_WAIST,), (FS_CHEST,)),
        "pelvis": ring((FS_PELVIS,), (FS_WAIST,)),
        "top": max((me.vertices[i].co for i in vs[FS_HEAD]), key=lambda c: c.z).copy(),
    }
    limbs = {}
    for sets in (FS_UPPER_ARM, FS_FOREARM, FS_HAND, FS_THIGH, FS_SHIN, FS_FOOT):
        for k in sets:
            limbs[(sets, side_of(me, vs[k]))] = k
    fingers = {s: {k for k in FS_FINGERS if k in vs and side_of(me, vs[k]) == s} for s in SIDES}
    toes = {s: {k for k in FS_TOES if k in vs and side_of(me, vs[k]) == s} for s in SIDES}
    for s in SIDES:
        ua, fa, ha = limbs[(FS_UPPER_ARM, s)], limbs[(FS_FOREARM, s)], limbs[(FS_HAND, s)]
        th, sh, ft = limbs[(FS_THIGH, s)], limbs[(FS_SHIN, s)], limbs[(FS_FOOT, s)]
        j["shoulder", s] = ring((FS_CHEST,), (ua,)) + Vector((0, 0, 0.02))
        j["elbow", s] = ring((ua,), (fa,))
        j["wrist", s] = ring((fa,), (ha,))
        j["knuckles", s] = ring((ha,), fingers[s])
        hand = group((ha,) + tuple(fingers[s]))
        j["hand_tip", s] = max((me.vertices[i].co for i in hand), key=lambda c: (c - j["wrist", s]).length).copy()
        j["fingers", s] = group(tuple(fingers[s]))
        j["hip", s] = ring((FS_PELVIS,), (th,)) + Vector((0, 0, 0.04))
        j["knee", s] = ring((th,), (sh,))
        j["ankle", s] = ring((sh,), (ft,)) + Vector((0, 0, 0.01))
        foot = group((ft,) + tuple(toes[s]))
        toe = max((me.vertices[i].co for i in foot), key=lambda c: c.y)
        j["toe", s] = Vector((toe.x, toe.y, 0.03))
    return j


# --- building ----------------------------------------------------------------

def place(body, eyes):
    """Body centered on the origin, facing +Y (-Z in Godot), feet on z = 0."""
    origin = body.matrix_world.translation.copy()
    turn = Matrix.Rotation(math.pi, 4, "Z") @ Matrix.Translation(-origin)
    for o in (*eyes, body):  # the eyes first: they are the body's children
        common.bake_world(o, turn)
    low = min(v.co.z for v in body.data.vertices)
    for o in (body, *eyes):
        o.data.transform(Matrix.Translation((0, 0, -low)))
        if o in eyes:
            for p in o.data.polygons:
                p.use_smooth = True


def armature(j):
    data = bpy.data.armatures.new("esqueleto")
    arm = bpy.data.objects.new("esqueleto", data)
    bpy.context.scene.collection.objects.link(arm)
    common.activate(arm)
    bpy.ops.object.mode_set(mode="EDIT")

    def bone(name, head, tail, parent=None):
        b = data.edit_bones.new(name)
        b.head, b.tail = head, tail
        if parent:
            b.parent = data.edit_bones[parent]

    hip = (j["hip", -1] + j["hip", 1]) / 2
    pelvis = Vector((0, j["pelvis"].y, j["pelvis"].z))
    neck = Vector((0, j["neck"].y, j["neck"].z))
    chest = Vector((0, j["waist"].y, j["waist"].z)).lerp(neck, 0.4)
    bone("hips", Vector((0, hip.y, hip.z)), pelvis)
    bone("spine", pelvis, chest, "hips")
    bone("chest", chest, neck, "spine")
    bone("head", neck, Vector((0, neck.y, j["top"].z)), "chest")
    for s, n in SIDES.items():
        bone("upper_arm" + n, j["shoulder", s], j["elbow", s], "chest")
        bone("forearm" + n, j["elbow", s], j["wrist", s], "upper_arm" + n)
        bone("hand" + n, j["wrist", s], j["hand_tip", s], "forearm" + n)
        bone("thigh" + n, j["hip", s], j["knee", s], "hips")
        bone("shin" + n, j["knee", s], j["ankle", s], "thigh" + n)
        bone("foot" + n, j["ankle", s], j["toe", s], "shin" + n)
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm


def skin(body, eyes, arm):
    common.activate(arm, [body])
    bpy.ops.object.parent_set(type="ARMATURE_AUTO")
    loose = sum(1 for v in body.data.vertices if sum(g.weight for g in v.groups) < 1e-3)
    print("figuras: %d vertices without weight" % loose)
    assert loose < 20, "bone heat failed"
    for e in eyes:
        e.vertex_groups.new(name="head").add(range(len(e.data.vertices)), 1.0, "REPLACE")
        e.modifiers.new("esqueleto", "ARMATURE").object = arm


def aim(pb, direction):
    head = pb.head.copy()
    turn = (pb.tail - head).normalized().rotation_difference(direction).to_matrix().to_4x4()
    pb.matrix = Matrix.Translation(head) @ turn @ Matrix.Translation(-head) @ pb.matrix
    bpy.context.view_layer.update()


def repose(body, eyes, arm, child):
    """Arms down (and child proportions), made the rest pose."""
    common.activate(arm)
    bpy.ops.object.mode_set(mode="POSE")
    a = math.radians(ARM_OUT)
    for s, n in SIDES.items():
        down = Vector((s * math.sin(a), 0.0, -math.cos(a)))
        aim(arm.pose.bones["upper_arm" + n], down)
        aim(arm.pose.bones["forearm" + n], (down + Vector((0, 0.1, 0))).normalized())
    if child:
        for name, k in CHILD.items():
            arm.pose.bones[name].scale = (k, k, k)
        bpy.context.view_layer.update()
    bpy.ops.object.mode_set(mode="OBJECT")
    for o in (body, *eyes):
        mod = next(m for m in o.modifiers if m.type == "ARMATURE")
        common.apply_modifier(o, mod.name)
    common.activate(arm)
    bpy.ops.object.mode_set(mode="POSE")
    bpy.ops.pose.armature_apply(selected=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    for o in (body, *eyes):
        o.modifiers.new("esqueleto", "ARMATURE").object = arm


def hairline(me, fs, j):
    """f(co) > 0 above a hairline that drops from the forehead to the nape."""
    top = j["top"].z
    crown = [p.center for p in me.polygons if fs[p.index] == FS_HEAD and p.center.z > top - 0.12]
    yc = sum(c.y for c in crown) / len(crown)

    def f(co):
        t = (1 - math.cos(math.atan2(co.x, co.y - yc))) / 2  # 0 at the front, 1 at the back
        return co.z - (top - (0.062 + 0.13 * t * t))
    return f


def cut_along(bm, faces, f):
    """Splits `faces` where f(co) crosses zero, so a border drawn by f is a clean
    curve and not the staircase of the quads it crosses."""
    made = set()
    for e in {e for fc in faces for e in fc.edges}:
        a, b = e.verts
        fa, fb = f(a.co), f(b.co)
        if (fa < 0) != (fb < 0):
            made.add(bmesh.utils.edge_split(e, a, fa / (fa - fb))[1])
    for fc in list({fc for v in made for fc in v.link_faces}):
        vs = [v for v in fc.verts if v in made]
        if len(vs) == 2 and vs[1] not in {e.other_vert(vs[0]) for e in vs[0].link_edges}:
            bmesh.utils.face_split(fc, vs[0], vs[1])


def regions(me, fs, j):
    """Cuts the hairline, the collar (the coat climbs the neck) and the hem
    (the coat comes down over the pelvis), then gives each face its slot.
    Returns (slot per face, face set per face), the mesh having new faces."""
    hair = hairline(me, fs, j)
    collar = j["neck"].z + COLLAR
    hem = j["hip", -1].z + HEM

    def low(co):
        return collar - co.z

    def high(co):
        return co.z - hem
    bm = bmesh.new()
    bm.from_mesh(me)
    sets = bm.faces.layers.int.new("_fs")
    for f, k in zip(bm.faces, fs):
        f[sets] = k
    head = [f for f in bm.faces if f[sets] == FS_HEAD]
    cut_along(bm, head, hair)
    cut_along(bm, [f for f in bm.faces if f[sets] == FS_HEAD], low)
    cut_along(bm, [f for f in bm.faces if f[sets] == FS_PELVIS], high)
    by_set = {}
    for name, (group, _, _) in CLOTHES.items():
        for k in group or ():
            by_set[k] = name
    out, new_fs = [], []
    for f in bm.faces:
        k, c = f[sets], f.calc_center_median()
        new_fs.append(k)
        if k == FS_HEAD and hair(c) > 0:
            out.append("hair")
        elif (k == FS_HEAD and low(c) > 0) or (k == FS_PELVIS and high(c) > 0):
            out.append("coat")
        else:
            out.append(by_set.get(k, "skin"))
    bm.faces.layers.int.remove(sets)
    bm.to_mesh(me)
    bm.free()
    me.update()
    return out, new_fs


def shoe(bm, verts, push):
    """Moves a foot onto its convex hull, `push` beyond it: a closed shoe, no toes."""
    hull = bmesh.new()
    bmesh.ops.convex_hull(hull, input=[hull.verts.new(v.co) for v in verts])
    tree = BVHTree.FromBMesh(hull)

    def onto(v, co):
        loc = tree.find_nearest(co)[0]
        if loc is not None:
            v.co = loc
    # Out along rays from the foot's long axis: unlike the nearest point, a ray
    # keeps the crevices between the toes in order, so nothing lands folded.
    c = sum((v.co for v in verts), Vector()) / len(verts)
    y0, y1 = min(v.co.y for v in verts), max(v.co.y for v in verts)
    a = Vector((c.x, y0 + 0.3 * (y1 - y0), c.z))
    ab = Vector((0, 0.45 * (y1 - y0), 0))
    def axis(co):
        return a + ab * min(1.0, max(0.0, (co - a).dot(ab) / ab.length_squared))
    for v in verts:
        p = axis(v.co)
        d = v.co - p
        hit = tree.ray_cast(p, d.normalized()) if d.length > 1e-6 else (None,)
        onto(v, hit[0] if hit[0] is not None else v.co)
    # Then every vertex slides toward its neighbours' average, kept on the
    # hull, which evens out the thin faces the crevices became.
    for _ in range(SHOE_RELAX):
        avg = [sum((e.other_vert(v).co for e in v.link_edges), Vector()) / len(v.link_edges)
               for v in verts]
        for v, co in zip(verts, avg):
            onto(v, co)
    # Pushed out along the same rays: the faces' own normals still point
    # inward where they were folded, and would dent the shoe.
    for v in verts:
        d = v.co - axis(v.co)
        if d.length > 1e-6:
            v.co += d.normalized() * push
    hull.free()


def slack(verts, passes):
    """A coat over the torso: plain smoothing takes out the chest and the
    belly, then each 2 cm slice gets its width back, so the torso keeps its
    size and only loses the relief."""
    orig = [v.co.copy() for v in verts]
    for _ in range(passes):
        avg = [sum((e.other_vert(v).co for e in v.link_edges), Vector()) / len(v.link_edges)
               for v in verts]
        for v, a in zip(verts, avg):
            v.co = v.co.lerp(a, 0.5)
    slices = defaultdict(list)
    for i, o in enumerate(orig):
        slices[math.floor(o.z / 0.02)].append(i)
    for idx in slices.values():
        if len(idx) < 8:
            continue
        c0 = sum((orig[i] for i in idx), Vector()) / len(idx)
        c1 = sum((verts[i].co for i in idx), Vector()) / len(idx)
        r0 = sum((orig[i] - c0).xy.length for i in idx) / len(idx)
        r1 = sum((verts[i].co - c1).xy.length for i in idx) / len(idx)
        k = r0 / r1 if r1 > 1e-6 else 1.0
        for i in idx:
            d = verts[i].co - c1
            verts[i].co = Vector((c0.x + d.x * k, c0.y + d.y * k, verts[i].co.z))


def taubin(bm, verts, passes):
    """Smooths `verts` without shrinking them (Taubin lambda/mu)."""
    verts = list(verts)
    for _ in range(passes):
        for k in (0.5, -0.53):
            moved = []
            for v in verts:
                ring = [e.other_vert(v).co for e in v.link_edges]
                avg = sum(ring, Vector()) / len(ring)
                moved.append(v.co + (avg - v.co) * k)
            for v, c in zip(verts, moved):
                v.co = c


def dress(me, region, fs, push=True):
    """Pushes each clothed region out along the normals, takes the muscles out
    of the coat's torso and smooths each region's inside."""
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.faces.ensure_lookup_table()
    push_of = {name: c[1] for name, c in CLOTHES.items()}
    shod = set()
    for side in SIDES:
        foot = [v for v in bm.verts if (v.co.x < 0) == (side < 0)
                and all(region[f.index] == "shoes" for f in v.link_faces)]
        shoe(bm, foot, push_of["shoes"] if push else 0.0)
        shod.update(foot)
    bm.normal_update()
    if push:
        offsets = []
        for v in bm.verts:
            ks = [push_of.get(region[f.index], 0.0) for f in v.link_faces]
            offsets.append(sum(ks) / len(ks))
        for v, d in zip(bm.verts, offsets):
            if v not in shod:
                v.co += v.normal * d
    trunk = {FS_CHEST, FS_WAIST, FS_PELVIS, FS_HEAD}
    slack([v for v in bm.verts if all(region[f.index] == "coat" and fs[f.index] in trunk
                                      for f in v.link_faces)], SLACK)
    for name, (_, _, passes) in CLOTHES.items():
        inside = [v for v in bm.verts if all(region[f.index] == name for f in v.link_faces)]
        taubin(bm, inside, passes)
    bm.to_mesh(me)
    bm.free()
    me.update()


def soften(me, fs):
    """The boy: a face without the man's brow, jaw and nose."""
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.faces.ensure_lookup_table()
    face = set(FS_FACE)
    taubin(bm, [v for v in bm.verts if all(fs[f.index] in face for f in v.link_faces)], CHILD_FACE)
    bm.to_mesh(me)
    bm.free()
    me.update()


def wear(me, fs, j):
    """The Gasto: a smoothed face with closed eyes and long fingers."""
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.faces.ensure_lookup_table()
    face = {k for k in FS_FACE}
    soft = [v for v in bm.verts if any(fs[f.index] in face for f in v.link_faces)]
    taubin(bm, soft, 14)
    bm.verts.ensure_lookup_table()
    for s in SIDES:
        d = (centroid(me, j["fingers", s]) - j["wrist", s]).normalized()
        k = j["knuckles", s]
        for i in j["fingers", s]:
            v = bm.verts[i]
            t = (v.co - k).dot(d)
            if t > 0:
                v.co += d * t * (FINGERS - 1)
    bm.to_mesh(me)
    bm.free()
    me.update()


def normalize(objs, arm):
    """Feet on z = 0 and the top of the head at HEIGHT."""
    zs = [(o.matrix_world @ v.co).z for o in objs for v in o.data.vertices]
    low, high = min(zs), max(zs)
    m = Matrix.Scale(HEIGHT / (high - low), 4) @ Matrix.Translation((0, 0, -low))
    for o in objs:
        o.data.transform(m)
    arm.data.transform(m)


def materials(body, eyes, region):
    mats = {}
    for m in list(bpy.data.materials):  # the source's own, so ours keep their names
        m.name = "_fonte_" + m.name
    for name in SLOTS:
        mat = bpy.data.materials.new(name)
        mats[name] = mat
        body.data.materials.append(mat)
    for p, name in zip(body.data.polygons, region):
        p.material_index = SLOTS.index(name)
    for e in eyes:
        me = e.data
        me.materials.clear()
        me.materials.append(mats["eyes"])
        me.materials.append(mats["iris"])
        center = centroid(me, range(len(me.vertices)))
        for p in me.polygons:
            ahead = (p.center - center).normalized().dot(Vector((0, 1, 0)))
            p.material_index = 1 if ahead > math.cos(math.radians(24)) else 0
    return mats


def join(body, eyes):
    if not eyes:
        return
    common.activate(body, eyes)
    with bpy.context.temp_override(active_object=body, selected_editable_objects=[body, *eyes]):
        bpy.ops.object.join()


def pack_uvs(body, fs_faces):
    """One 0-1 tile (the source spreads over UDIM tiles), the head at twice
    the texel density of the rest: the Gasto's face is seen up close."""
    me = body.data
    for d in me.uv_layers[0].data:
        d.uv /= 9.0
    common.activate(body)
    bpy.context.scene.tool_settings.use_uv_select_sync = True
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.average_islands_scale()
    bm = bmesh.from_edit_mesh(me)
    uv = bm.loops.layers.uv.active
    bm.faces.index_update()
    head = {FS_HEAD, *FS_FACE}
    for island in bmesh_linked_uv_islands(bm, uv):
        if sum(1 for f in island if f.index < len(fs_faces) and fs_faces[f.index] in head) * 2 < len(island):
            continue
        loops = [l for f in island for l in f.loops]
        mid = sum((l[uv].uv for l in loops), Vector((0, 0))) / len(loops)
        for l in loops:
            l[uv].uv = mid + (l[uv].uv - mid) * 2.0
    bmesh.update_edit_mesh(me)
    bpy.ops.uv.pack_islands(udim_source="CLOSEST_UDIM", rotate=True, margin=0.004)
    bpy.ops.object.mode_set(mode="OBJECT")
    us = [d.uv for d in me.uv_layers[0].data]
    print("figuras: uv range u %.3f..%.3f v %.3f..%.3f" % (
        min(u.x for u in us), max(u.x for u in us), min(u.y for u in us), max(u.y for u in us)))


def node(tree, kind, inputs=None, **named):
    """A new node; `inputs` and `named` set input defaults by index or name."""
    n = tree.nodes.new(kind)
    for k, v in {**(inputs or {}), **named}.items():
        n.inputs[k].default_value = v
    return n


def crack_layer(tree, coords, scale, width):
    """1 on a crack line, 0 elsewhere: the edges of a distorted Voronoi."""
    noise = node(tree, "ShaderNodeTexNoise", Scale=scale * 0.35, Detail=3.0)
    noise.noise_dimensions = "3D"
    warp = node(tree, "ShaderNodeVectorMath")
    warp.operation = "MULTIPLY_ADD"
    warp.inputs[1].default_value = (0.35 / scale,) * 3
    tree.links.new(noise.outputs["Color"], warp.inputs[0])
    tree.links.new(coords, warp.inputs[2])
    vor = node(tree, "ShaderNodeTexVoronoi", Scale=scale, Randomness=0.9)
    vor.feature = "DISTANCE_TO_EDGE"
    tree.links.new(warp.outputs[0], vor.inputs["Vector"])
    line = node(tree, "ShaderNodeMapRange")
    line.inputs["From Min"].default_value = width
    line.inputs["From Max"].default_value = 0.0
    tree.links.new(vor.outputs["Distance"], line.inputs["Value"])
    return line.outputs["Result"]


def bake_texture(name, body, mats, cfg):
    """AO x craquelê into one gray 1K map."""
    img = bpy.data.images.new(name, 1024, 1024, alpha=False)
    for slot, mat in mats.items():
        mat.use_nodes = True
        tree = mat.node_tree
        tree.nodes.clear()
        out = node(tree, "ShaderNodeOutputMaterial")
        emit = node(tree, "ShaderNodeEmission", Strength=1.0)
        tree.links.new(emit.outputs[0], out.inputs["Surface"])
        ao = node(tree, "ShaderNodeAmbientOcclusion", Distance=0.12)
        ao.samples = 24
        ao.only_local = True
        light = node(tree, "ShaderNodeMapRange", {"To Min": 0.28, "To Max": 1.0})
        tree.links.new(ao.outputs["AO"], light.inputs["Value"])
        coords = node(tree, "ShaderNodeTexCoord").outputs["Object"]
        porcelain = slot not in ("eyes", "iris")
        fine = cfg["fine"] * (1.0 if slot == "skin" else 0.6) if porcelain else 0.0
        coarse = cfg["coarse"] * (1.0 if slot == "skin" else 0.35) if porcelain else 0.0
        value = light.outputs["Result"]
        for strength, scale, width in ((fine, 52.0, 0.08), (coarse, 7.0, 0.035)):
            if strength <= 0:
                continue
            dark = node(tree, "ShaderNodeMath", {1: strength})
            dark.operation = "MULTIPLY"
            tree.links.new(crack_layer(tree, coords, scale, width), dark.inputs[0])
            keep = node(tree, "ShaderNodeMath", {0: 1.0})
            keep.operation = "SUBTRACT"
            tree.links.new(dark.outputs[0], keep.inputs[1])
            mul = node(tree, "ShaderNodeMath")
            mul.operation = "MULTIPLY"
            tree.links.new(value, mul.inputs[0])
            tree.links.new(keep.outputs[0], mul.inputs[1])
            value = mul.outputs[0]
        tree.links.new(value, emit.inputs["Color"])
        tex = tree.nodes.new("ShaderNodeTexImage")
        tex.image = img
        tree.nodes.active = tex
    common.bake_emit(body)
    common.save_png(img, os.path.join(common.TEXTURES, name + ".png"))
    return img


def hex_color(h):
    h = h.lstrip("#")
    srgb = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb) + (1.0,)


def surface(mats, colors, img=None):
    """Plain materials for export, or the baked map times the colors for a preview."""
    for slot, mat in mats.items():
        tree = mat.node_tree
        tree.nodes.clear()
        out = node(tree, "ShaderNodeOutputMaterial")
        bsdf = node(tree, "ShaderNodeBsdfPrincipled", Roughness=ROUGHNESS[slot])
        tree.links.new(bsdf.outputs[0], out.inputs["Surface"])
        color = hex_color(colors.get(slot, DEFAULTS.get(slot, colors.get("skin"))))
        if img is None:
            bsdf.inputs["Base Color"].default_value = color
            continue
        tex = tree.nodes.new("ShaderNodeTexImage")
        tex.image = img
        tint = node(tree, "ShaderNodeVectorMath", {1: color[:3]})
        tint.operation = "MULTIPLY"
        tree.links.new(tex.outputs["Color"], tint.inputs[0])
        tree.links.new(tint.outputs[0], bsdf.inputs["Base Color"])


def turn(pb, degrees, axis="X"):
    """Rotates a pose bone about its head, in armature space."""
    h = pb.head.copy()
    pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(degrees), 4, axis) @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()


def preview(name, body, arm, mats, img, out_dir):
    surface(mats, PREVIEW[name], img)
    prefix = os.path.join(out_dir, name)
    common.render_views(prefix, {
        "frente": ((1.3, 3.6, 1.15), 50, (0, 0, 0.9)),
        "rosto": ((0.18, 0.75, 1.62), 70, (0, 0, 1.6)),
        "costas": ((-1.6, -3.2, 1.3), 50, (0, 0, 0.9)),
    })
    common.activate(arm)
    bpy.ops.object.mode_set(mode="POSE")
    pb = arm.pose.bones
    for n in SIDES.values():  # seated, leaning in, one hand out (+X turns a limb forward)
        turn(pb["thigh" + n], 82)
        turn(pb["shin" + n], -84)
    turn(pb["spine"], -12)
    turn(pb["upper_arm.R"], 70)
    turn(pb["head"], -15)
    bpy.ops.object.mode_set(mode="OBJECT")
    common.render_views(prefix, {"sentado": ((2.6, 2.4, 1.1), 45, (0, 0.2, 0.7))})
    common.activate(arm)
    bpy.ops.object.mode_set(mode="POSE")
    bpy.ops.pose.select_all(action="SELECT")
    bpy.ops.pose.transforms_clear()
    bpy.ops.object.mode_set(mode="OBJECT")


def build(name, cfg, src, preview_dir):
    print("figuras: building", name)
    common.open_blend(src)
    body = bpy.data.objects[BODY]
    eyes = [bpy.data.objects[n] for n in EYES]
    common.isolate([body, *eyes])
    multires = next(m for m in body.modifiers if m.type == "MULTIRES")
    common.activate(body)
    with bpy.context.temp_override(object=body, active_object=body):
        bpy.ops.object.multires_base_apply(modifier=multires.name)
    body.modifiers.remove(multires)
    place(body, eyes)
    me = body.data
    fs = face_sets(me)
    arm = armature(joints(me, fs))
    skin(body, eyes, arm)
    repose(body, eyes, arm, cfg["child"])
    region, fs = regions(me, fs, joints(me, fs))
    j = joints(me, fs)
    dress(me, region, fs)
    if cfg["child"]:
        soften(me, fs)
    if cfg["worn"]:
        wear(me, fs, j)
        for e in eyes:
            bpy.data.objects.remove(e, do_unlink=True)
        eyes = []
    normalize([body, *eyes], arm)
    mats = materials(body, eyes, region)
    join(body, eyes)
    pack_uvs(body, fs)
    img = bake_texture(name, body, mats, cfg)
    if preview_dir:
        preview(name, body, arm, mats, img, preview_dir)
    surface(mats, PREVIEW[name])
    path = os.path.join(common.MODELS, name + ".glb")
    common.export_glb(path, [arm, body])
    print("figuras: wrote %s (%d vertices, %d faces)" % (path, len(body.data.vertices), len(body.data.polygons)))


def main():
    args = common.script_args()
    preview_dir = None
    if "--preview" in args:
        i = args.index("--preview")
        preview_dir = os.path.abspath(args[i + 1])
        del args[i:i + 2]
    names = args or list(VARIANTS)
    src = bpy.data.filepath
    for name in names:
        build(name, VARIANTS[name], src, preview_dir)


main()
