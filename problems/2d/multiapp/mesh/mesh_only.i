# Geometric settings
pitch = '${units 0.032 m}'
half_pitch = '${fparse 0.5 * ${pitch}}'

[Mesh]
  [fuel_rod]
    type = ConcentricCircleMeshGenerator
    #num_sectors = 6
    num_sectors = 10
    radii = '0.00918 0.00934 0.01054' # meters
    #rings = '4 1 2 3'
    rings = '5 1 3 5'
    has_outer_square = true
    pitch = ${pitch}
    preserve_volumes = true
  []

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
