# Geometric settings
pitch = '${units 0.032 m}'
half_pitch = '${fparse 0.5 * ${pitch}}'

[Mesh]
  [fluid_rod]
    type = GeneratedMeshGenerator
    dim = 2

    xmin = -${half_pitch}
    xmax = ${half_pitch}
    ymin = -${half_pitch}
    ymax = ${half_pitch}

    nx = 14
    ny = 14
  []
  [rename_block_name]
    type = RenameBlockGenerator
    input = fluid_rod
    old_block = '0'
    new_block = 'fluid_block'
  []
[]

[Outputs]
  exodus = true
[]
