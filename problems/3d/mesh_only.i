[Mesh]

  [fluid_rod]
    type = GeneratedMeshGenerator
    dim = 2

    xmin = -0.016
    xmax = 0.016
    ymin = -0.016
    ymax = 0.016

    nx = 14
    ny = 14
  []

  [fuel_rod]
    type = ConcentricCircleMeshGenerator
    num_sectors = 4
    radii = '0.00918 0.00934 0.01054' # meters
    rings = '4 2 3 4'
    has_outer_square = on
    pitch = 0.032
    preserve_volumes = false
  []

  [pmg]
    type = PatternedMeshGenerator
    inputs = 'fluid_rod fuel_rod'
    pattern = '0 1
               '
  []

[]

[Outputs]
  exodus = true
[]
