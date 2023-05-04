import numpy as np
from matplotlib import pyplot as plt
from matplotlib.animation import FuncAnimation
from scipy.stats import qmc

num_points = 2000
tol = 0.001

class LHSSampler:

    def __init__(self, num_points):
        self.num_points = num_points
        self.batch_id = 0
        self.sample_id = 0

        self.sampler = qmc.LatinHypercube(d=2)
        self.data = self.sampler.random(self.num_points)
    
    def NextSample(self):
        if self.sample_id < self.num_points:
            sample = self.data[self.sample_id]
            self.sample_id += 1
            return np.array([sample])

        else:
            self.batch_id += 1
            print ("Generating batch", self.batch_id)
            self.data = self.sampler.random(self.num_points)
            self.sample_id = 0
            return self.NextSample()


lhs_sampler = LHSSampler(num_points)
np.random.seed(4321)

def GetSample(a, b, old_samples, exclusion_radius=0.03):
    while True:
        #sample = np.random.random_sample(size=(1,2))
        sample = lhs_sampler.NextSample()
        sample = a + (b - a) * sample

        distance_to_other_samples = np.linalg.norm(sample - old_samples, axis=1)

        #print(f"{sample=}")
        #print(f"{old_samples=}")
        #print(f"{distance_to_other_samples=}")

        if np.all(distance_to_other_samples > exclusion_radius):
            return sample


x_bounds = (0.0 + tol, 0.3683 - tol)
y_start = 0.0127 + 0.2292
y_bounds = (y_start + tol, y_start + 2.5146 - tol)

a = np.array([[x_bounds[0], y_bounds[0]]])
b = np.array([[x_bounds[1], y_bounds[1]]])


fig, ax = plt.subplots(figsize=(4,12))
ax.set_aspect('equal')
plt.xlim(0, x_bounds[1])
plt.ylim(0, y_bounds[1] + y_start)
plt.hlines(y=[y_start, y_bounds[1]], xmin=[0, 0], xmax=[x_bounds[1], x_bounds[1]], color="k")

xdata, ydata = [], []
ln, = plt.plot([], [], 'x', ms=2)
title = plt.title("0")

def update(frame):
    samples = np.hstack([xdata, ydata]).reshape((-1,2))
    sample = GetSample(a, b, samples)
    xdata.append(sample[0,0])
    ydata.append(sample[0,1])
    ln.set_data(xdata, ydata)
    title.set_text(len(xdata))
    return ln,

ani = FuncAnimation(fig, update, frames=num_points-1, interval=1, blit=False, repeat=False)

plt.show()

parsed_func = "expression = 'if("
for x, y in zip(xdata, ydata):
    conditional = f"((abs(x - {x:.5f}) < {tol}) & (abs(y - {y:.5f}) < {tol}))"
    parsed_func += conditional + " | "

parsed_func = parsed_func[:-3] + ", Q, 0)'"

print(parsed_func)

print(len(xdata), len(ydata))