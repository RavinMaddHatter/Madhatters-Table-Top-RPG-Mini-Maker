@tool
extends MeshInstance3D
class_name HumanizerMeshInstance

@export var material_config: HumanizerMaterial:
	set(value):
		if material_config != value:
			material_config = value
			initialize()

func initialize() -> void:
	# Make everything local
	if get_surface_override_material(0) != null:
		get_surface_override_material(0).resource_local_to_scene = true
	material_config.resource_local_to_scene = true
	if not material_config.on_material_updated.is_connected(update_material):
		material_config.on_material_updated.connect(update_material)
	
func update_material() -> void:
	var mat: BaseMaterial3D = get_surface_override_material(0)
	if mat == null:
		mat = StandardMaterial3D.new()
		set_surface_override_material(0, mat)
	mat.normal_enabled = material_config.normal_texture != null
	mat.ao_enabled = material_config.ao_texture != null
	mat.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, material_config.albedo_texture)
	mat.set_texture(BaseMaterial3D.TEXTURE_NORMAL, material_config.normal_texture)
	mat.set_texture(BaseMaterial3D.TEXTURE_AMBIENT_OCCLUSION, material_config.ao_texture)

	if get_parent_node_3d():
		get_parent_node_3d().human_config.material_configs[name] = material_config
