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
    radii = '${r_fuel} ${r_gap} ${r_clad} ${r_extra_block}' # meters
    rings = '4 1 2 1 3'
    has_outer_square = true
    pitch = ${pitch}
    preserve_volumes = true
  []
  #[rename_block]
  #  type = RenameBlockGenerator
  #  input = fuel_rod
  #  old_block = 5
  #  new_block = 0
  #[]

  #[fluid_rod]
  #  type = GeneratedMeshGenerator
  #  dim = 2

  #  xmin = -${half_pitch}
  #  xmax = ${half_pitch}
  #  ymin = -${half_pitch}
  #  ymax = ${half_pitch}

  #  nx = 14
  #  ny = 14
  #[]
[]

[Outputs]
  exodus = true
[]
