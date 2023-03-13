# Geometric settings
pitch = '${units 0.032 m}'
half_pitch = '${fparse 0.5 * ${pitch}}'

r_fuel = '${units 0.00918 m}'
r_gap = '${units 0.00934 m}'
r_clad = '${units 0.01054 m}'

[Mesh]
  [fuel_rod]
    type = ConcentricCircleMeshGenerator
    #num_sectors = 6
    num_sectors = 10
    radii = '${r_fuel} ${r_gap} ${r_clad}' # meters
    #rings = '4 1 2'
    rings = '5 1 3'
    has_outer_square = false
    pitch = ${pitch}
    preserve_volumes = true
  []
  [rename_block_name]
    type = RenameBlockGenerator
    input = fuel_rod
    old_block = '1 2 3'
    new_block = 'fuel_block gap_block clad_block'
  []
  [fuel_gap_interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = 'rename_block_name'
    paired_block = 'fuel_block'
    primary_block = 'gap_block'
    new_boundary = 'fuel_gap_interface'
  []

  [gap_clad_interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = 'fuel_gap_interface'
    paired_block = 'gap_block'
    primary_block = 'clad_block'
    new_boundary = 'gap_clad_interface'
  []
[]

[Outputs]
  exodus = true
[]
