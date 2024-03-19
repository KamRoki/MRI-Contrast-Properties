import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# -------------------------------------------------------------------------
# DATA (Before that, create Excel file)
data_path = '/Users/kamil/Desktop/'  # Folder path
scan_name = 'Sample 1'  # Scan folder
savename = 'Non-filtred and sonificated CeO2-Gd-PAA'
init_concentration = 27.7  # [mM]
rangeT1 = 'A9:AB15'
rangeT2 = 'A9:AB30'
do_relaxivity = 1
# -------------------------------------------------------------------------
dataBaseT2 = pd.read_excel(data_path + scan_name + '/sample_1_t2_map.xlsx', sheet_name=0, usecols=rangeT2)
TE = dataBaseT2.iloc[:, 0]  # [ms]
signalT2 = dataBaseT2.iloc[:, [13, 16, 19, 22]].values

dataBaseT1 = pd.read_excel(data_path + scan_name + '/sample_1_t1_map.xlsx', sheet_name=0, usecols=rangeT1)
TR = dataBaseT1.iloc[:, 0]  # [ms]
signalT1 = dataBaseT1.iloc[:, [13, 16, 19, 22]].values

concentration = init_concentration * np.array([1/128, 1/64, 1/32, 1/16])  # [mM]

color = ['r*', 'g*', 'b*', 'c*']
colorFit = ['r-', 'g-', 'b-', 'c-']
# -------------------------------------------------------------------------
# T1 RELAXATION
fT1 = plt.figure()
T1values = []
for icnt in range(len(concentration)):
    plt.plot(TR, signalT1[:, icnt], color[icnt])
    popt, _ = curve_fit(lambda x, A, T: A * (1 - np.exp(-x / T)), TR, signalT1[:, icnt], p0=[120, 500])
    plt.plot(TR, popt[0] * (1 - np.exp(-TR / popt[1])), colorFit[icnt])
    T1values.append(popt[1])
    print('T1 Relaxation results for', icnt)
    print('T:', popt[1])
plt.grid(True, which='both', linestyle='--')
plt.xlabel('TR [ms]')
plt.ylabel('Signal Intensity')
plt.title('T1 Relaxation of ' + savename)
plt.show()
# -------------------------------------------------------------------------
# T2 RELAXATION
fT2 = plt.figure()
T2values = []
for icnt in range(len(concentration)):
    plt.plot(TE, signalT2[:, icnt], color[icnt])
    popt, _ = curve_fit(lambda x, A, T: A * np.exp(-x / T), TE, signalT2[:, icnt], p0=[0.8, 0.7])
    plt.plot(TE, popt[0] * np.exp(-TE / popt[1]), colorFit[icnt])
    T2values.append(popt[1])
    print('T2 Relaxation result for', icnt)
    print('T:', popt[1])
plt.grid(True, which='both', linestyle='--')
plt.xlabel('TE [ms]')
plt.ylabel('Signal Intensity')
plt.title('T2 Relaxation of ' + savename)
plt.show()
# -------------------------------------------------------------------------
# RELAXIVITIES
if do_relaxivity == 1:
    # R1
    fR1 = plt.figure()
    R1values = (1 / np.array(T1values)) * 1000  # [1/s]
    plt.plot(concentration, np.flip(R1values), 'b*')
    popt, _ = curve_fit(lambda x, r, R: r * x + R, concentration, np.flip(R1values), p0=[0.75, 0.67])
    plt.plot(concentration, popt[0] * concentration + popt[1], 'b-')
    r1 = popt[0]
    print('Molar Relaxivity r1 results:')
    print('r:', r1)
    plt.grid(True, which='both', linestyle='--')
    plt.xlabel('Concentration [mM]')
    plt.ylabel('Relaxation rate [1/s]')
    plt.title('Molar relaxivity r1 of ' + savename)
    plt.show()
    # R2
    fR2 = plt.figure()
    R2values = (1 / np.array(T2values)) * 1000  # [1/s]
    plt.plot(concentration, np.flip(R2values), 'r*')
    popt, _ = curve_fit(lambda x, r, R: r * x + R, concentration, np.flip(R2values), p0=[0.75, 0.67])
    plt.plot(concentration, popt[0] * concentration + popt[1], 'r-')
    r2 = popt[0]
    print('Molar Relaxivity r2 results:')
    print('r:', r2)
    plt.grid(True, which='both', linestyle='--')
    plt.xlabel('Concentration [mM]')
    plt.ylabel('Relaxation rate [1/s]')
    plt.title('Molar relaxivity r2 of ' + savename)
    plt.show()
