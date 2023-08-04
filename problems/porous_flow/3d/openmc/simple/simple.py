import numpy as np

import openmc
import openmc.mgxs as mgxs


# create a model object to tie geometry, materials, settings, and tallies together
model = openmc.Model()


# Instantiate a Material and register the Nuclides
inf_medium = openmc.Material(name='moderator')
inf_medium.set_density('g/cc', 5.)
inf_medium.add_nuclide('C12', 0.01450188)
inf_medium.add_nuclide('U235', 0.000114142)
inf_medium.add_nuclide('U238', 0.006886019)


# Instantiate a Materials collection and export to XML
model.materials = openmc.Materials([inf_medium])
model.materials.export_to_xml()

# Lengths in cm
thickness = 1.27
inner_radius = 36.83
inner_height = 251.46

outer_radius = inner_radius + thickness
total_height = 2 * thickness + inner_height


# Instantiate boundary Planes
#inner_tube = openmc.ZCylinder(r=inner_radius)
outer_tube = openmc.ZCylinder(r=outer_radius, boundary_type='vacuum')

bottom = openmc.ZPlane(z0=0.0, boundary_type='vacuum')
#cavity_start = openmc.ZPlane(z0=thickness)
#cavity_end = openmc.ZPlane(z0=thickness + inner_height)
top = openmc.ZPlane(z0=total_height, boundary_type='vacuum')

print(outer_radius, total_height)


# Instantiate a Cell
cell = openmc.Cell(cell_id=1, name='cell')

# Register bounding Surfaces with the Cell
cell.region = +bottom & -top & -outer_tube

# Fill the Cell with the Material
cell.fill = inf_medium


# Create root universe
root_universe = openmc.Universe(name='root universe', cells=[cell])


# Create Geometry and set root Universe
model.geometry = openmc.Geometry(root_universe)
model.geometry.export_to_xml()


# OpenMC simulation parameters
batches = 50
inactive = 10
particles = 2500
#generations_per_batch = 1

# Instantiate a Settings object
settings = openmc.Settings()
settings.batches = batches
settings.inactive = inactive
settings.particles = particles
#settings.generations_per_batch = generations_per_batch
settings.output = {'tallies': True}

# Create an initial uniform spatial source distribution over fissionable zones
r_dist = openmc.stats.Uniform(0, inner_radius)
phi_dist = openmc.stats.Uniform(0, 2*np.pi)
z_dist = openmc.stats.Uniform(thickness, thickness + inner_height)
uniform_dist = openmc.stats.CylindricalIndependent(r_dist, phi_dist, z_dist)
settings.source = openmc.Source(space=uniform_dist)

model.settings = settings
settings.export_to_xml()


# Instantiate a 2-group EnergyGroups object
groups = mgxs.EnergyGroups(group_edges=np.array([0., 0.625, 20.0e6]))


# Instantiate a few different sections
total = mgxs.TotalXS(domain=cell, energy_groups=groups)
absorption = mgxs.AbsorptionXS(domain=cell, energy_groups=groups)
scattering = mgxs.ScatterXS(domain=cell, energy_groups=groups)

# Note that if we wanted to incorporate neutron multiplication in the
# scattering cross section we would write the previous line as:
# scattering = mgxs.ScatterXS(domain=cell, energy_groups=groups, nu=True)


# Instantiate an empty Tallies object
tallies = openmc.Tallies()

# Add total tallies to the tallies file
tallies += total.tallies.values()

# Add absorption tallies to the tallies file
tallies += absorption.tallies.values()

# Add scattering tallies to the tallies file
tallies += scattering.tallies.values()

model.tallies = tallies

tallies.export_to_xml()

# Geometry plot
vox_plot = openmc.Plot()
vox_plot.type = 'voxel'
vox_plot.origin = (0., 0., total_height/2)
vox_plot.width = (outer_radius*2, outer_radius*2, total_height)
vox_plot.pixels = (100, 100, 100)

plots = openmc.Plots([vox_plot])
plots.export_to_xml()
