import matplotlib
matplotlib.use("TkAgg")

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import serial

# Serial config
ser = serial.Serial("COM4", baudrate=115200, timeout=0.01)

# Plot config
window_size = 500
xdata = deque(maxlen=window_size)
ydata = deque(maxlen=window_size)

fig, ax = plt.subplots()
line, = ax.plot([], [], lw=2)
ax.set_ylim(-0.5, 1.5)       
ax.set_xlim(0, window_size)
ax.set_xlabel("Samples")
ax.set_ylabel("Switch state")

def update(frame):
    # flush all waiting bytes and keep only the latest
    latest_byte = None
    while ser.in_waiting > 0:
        latest_byte = ser.read(1)

    if latest_byte is not None:
        value = latest_byte[0]  # 0x00 or 0x01
    else:
        value = ydata[-1] if len(ydata) > 0 else 0.0

    # Update buffers
    if len(xdata) == 0:
        xdata.append(0)
    else:
        xdata.append(xdata[-1] + 1)
    ydata.append(value)

    line.set_data(range(len(ydata)), ydata)
    return line,

ani = animation.FuncAnimation(
    fig, update, interval=10, blit=True, cache_frame_data=False
)

plt.show()

