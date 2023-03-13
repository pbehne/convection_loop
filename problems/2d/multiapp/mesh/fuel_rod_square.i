# Geometric settings
pitch = '${units 0.032 m}'
half_pitch = '${fparse 0.5 * ${pitch}}'

r_fuel = '${units 0.00918 m}'
r_gap = '${units 0.00934 m}'
r_clad = '${units 0.01054 m}'
r_extra_block = '${fparse r_clad + (r_gap - r_fuel)}'

[Mesh]
  [fuel_rod]
    type = ConcentricCircleMeshGenerator
    num_sectors = 6
    #num_sectors = 10
    radii = '${r_fuel} ${r_gap} ${r_clad} ${r_extra_block}' # meters
    rings = '4 1 2 1 3'
    #rings = '5 1 3 1 5'
    has_outer_square = true
    pitch = ${pitch}
    preserve_volumes = true
  []
  [rename_block_id]
    type = RenameBlockGenerator
    input = fuel_rod
    old_block = 5
    new_block = 0
  []
  [rename_block_name]
    type = RenameBlockGenerator
    input = rename_block_id
    old_block = '0 1 2 3 4'
    new_block = 'fluid_block fuel_block gap_block clad_block small_fluid_block'
  []
  [mesh]
    type = SideSetsBetweenSubdomainsGenerator
    input = rename_block_name
    paired_block = 'clad_block'
    primary_block = 'small_fluid_block'
    new_boundary = 'outer'
  []
[]

[Outputs]
  exodus = true
[]
