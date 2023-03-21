[Mesh]
  [pmg]
    type = FileMeshGenerator
    file = 'mesh/quarter_cask_2d.e'
  []

  [mesh_extruded]
    type = AdvancedExtruderGenerator
    input = pmg
    direction = '0 0 1'
    heights = '1.0 0.00016 0.0012 0.00016 4.0 0.00016 0.0012 0.00016 1.0'
    num_layers = '361 1 1 1 1750 1 1 1 361'
    bottom_boundary = 500
    top_boundary = 600
    subdomain_swaps = '1 0 2 0 3 0 4 0;
                       1 4 2 4 3 4 4 4;
                       1 3 2 3 3 3 4 4;
                       1 2 2 2 3 3 4 4;
                       1 1 2 2 3 3 4 4;
                       1 2 2 2 3 3 4 4;
                       1 3 2 3 3 3 4 4;
                       1 4 2 4 3 4 4 4;
                       1 0 2 0 3 0 4 0
                      '
  []

  [mesh]
    type = SideSetsBetweenSubdomainsGenerator
    input = 'mesh_extruded'
    paired_block = '3'
    primary_block = '4'
    new_boundary = 'outer'
  []

  [rename_boundaries]
    type = RenameBoundaryGenerator
    input = mesh
    old_boundary = 'top bottom'
    new_boundary = 'front back'
  []

  [rename_boundaries2]
    type = RenameBoundaryGenerator
    input = rename_boundaries
    old_boundary = '500 600'
    new_boundary = 'bottom top'
  []

  [rename_block_name]
    type = RenameBlockGenerator
    input = rename_boundaries2
    old_block = '0 1 2 3 4'
    new_block = 'fluid_block fuel_block gap_block clad_block small_fluid_block'
  []
[]

[Outputs]
  exodus = true
[]