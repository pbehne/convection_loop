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
[]

[Outputs]
  exodus = true
[]
