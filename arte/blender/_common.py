"""Helpers shared by the asset scripts in arte/blender/ (spec §14.2).

Each script runs headless from the repo root, on a raw file from arte/fontes/:

    blender -b --factory-startup --disable-autoexec <raw .blend> \\
        --python arte/blender/<asset>.py -- <args>

and writes into Janghyang/assets/. Every edit to a raw file is code, so the
asset can be rebuilt and tuned later; no hand-edited .blend.
"""
import os
import sys

import bpy
from mathutils import Matrix, Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MODELS = os.path.join(ROOT, "Janghyang", "assets", "models")
TEXTURES = os.path.join(ROOT, "Janghyang", "assets", "textures")


def script_args():
    """The arguments after `--` on the blender command line."""
    argv = sys.argv
    return argv[argv.index("--") + 1:] if "--" in argv else []


def open_blend(path):
    bpy.ops.wm.open_mainfile(filepath=path, load_ui=False, use_scripts=False)


def isolate(objects):
    """Deletes every other object and moves `objects` to the scene's own
    collection, visible and selectable (the raw files hide and exclude theirs)."""
    keep = set(objects)
    for o in list(bpy.data.objects):
        if o not in keep:
            bpy.data.objects.remove(o, do_unlink=True)
    scene = bpy.context.scene
    for o in objects:
        for c in list(o.users_collection):
            c.objects.unlink(o)
        scene.collection.objects.link(o)
        o.hide_viewport = False
        o.hide_render = False
        o.hide_set(False)
        o.hide_select = False
        if o.data is not None and o.data.users > 1:
            o.data = o.data.copy()


def bake_world(obj, matrix=None):
    """Writes `matrix @ world transform` into the object's data, then clears
    its parent and transform."""
    mw = obj.matrix_world.copy()
    obj.parent = None
    obj.data.transform((matrix or Matrix.Identity(4)) @ mw)
    obj.matrix_world = Matrix.Identity(4)


def activate(obj, others=()):
    """Makes `obj` the active object, with `others` selected beside it."""
    layer = bpy.context.view_layer
    if bpy.context.object is not None and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    for o in layer.objects:
        o.select_set(False)
    for o in (obj, *others):
        o.select_set(True)
    layer.objects.active = obj


def apply_modifier(obj, name):
    activate(obj)
    with bpy.context.temp_override(object=obj, active_object=obj):
        bpy.ops.object.modifier_apply(modifier=name)


def bake_emit(obj, samples=8, margin=6):
    """Bakes the emission of every material of `obj` into the image of each
    material's active Image Texture node (Cycles, CPU)."""
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = samples
    scene.render.bake.target = "IMAGE_TEXTURES"
    scene.render.bake.margin = margin
    scene.render.bake.use_clear = True
    activate(obj)
    bpy.ops.object.bake(type="EMIT", margin=margin, use_clear=True)


def save_png(image, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image.filepath_raw = path
    image.file_format = "PNG"
    image.save()


def export_glb(path, objects):
    """Exports `objects` as one .glb (Y up), without textures: Godot sets the
    materials in code from assets/textures/."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    activate(objects[0], objects[1:])
    bpy.ops.export_scene.gltf(
        filepath=path, export_format="GLB", use_selection=True,
        export_yup=True, export_apply=False, export_animations=False,
        export_skins=True, export_morph=False, export_materials="EXPORT",
        export_image_format="NONE", export_cameras=False, export_lights=False,
        export_extras=False)


def render_views(path_prefix, views, size=(700, 900), samples=24):
    """Renders a few still views of the scene (Cycles, CPU) for checking a
    result by eye. `views` maps a suffix to (camera location, lens mm, aim point)."""
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = samples
    scene.render.resolution_x, scene.render.resolution_y = size
    scene.render.film_transparent = False
    world = scene.world or bpy.data.worlds.new("preview")
    scene.world = world
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.05, 0.05, 0.055, 1)
    key = bpy.data.objects.new("key", bpy.data.lights.new("key", "AREA"))
    key.data.energy, key.data.size = 350, 1.5
    key.location = (1.6, 2.4, 2.6)
    key.rotation_euler = (Vector((0, 0, 1.2)) - key.location).to_track_quat("-Z", "Y").to_euler()
    rim = bpy.data.objects.new("rim", bpy.data.lights.new("rim", "AREA"))
    rim.data.energy, rim.data.size = 160, 1.0
    rim.location = (-1.8, -2.0, 2.2)
    rim.rotation_euler = (Vector((0, 0, 1.2)) - rim.location).to_track_quat("-Z", "Y").to_euler()
    cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
    for o in (key, rim, cam):
        scene.collection.objects.link(o)
    scene.camera = cam
    for suffix, (loc, lens, aim) in views.items():
        cam.data.lens = lens
        cam.location = loc
        cam.rotation_euler = (Vector(aim) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()
        scene.render.filepath = "%s-%s.png" % (path_prefix, suffix)
        bpy.ops.render.render(write_still=True)
    for o in (key, rim, cam):
        bpy.data.objects.remove(o, do_unlink=True)
