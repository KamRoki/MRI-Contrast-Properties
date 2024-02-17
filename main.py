# import numpy as np
# import matplotlib.pyplot as plt
# import seaborn as sns
# from scipy.optimize import curve_fit

# # Ustawienie stylu seaborn
# sns.set_style("whitegrid")

# # Poniżej definiujemy funkcję, którą będziemy dopasowywać do danych
# def model(x, A, T):
#     return A * np.exp(-x / T)

# # Wczytujemy dane z pliku CSV (załóżmy, że dane są w dwóch kolumnach: x i y)
# data = np.loadtxt('nazwa_pliku.csv', delimiter=',')

# x_data = data[:, 0]
# y_data = data[:, 1]

# # Tworzymy początkowe przybliżenie parametrów A i T
# initial_guess = (1.0, 1.0)

# # Dopasowujemy krzywą do danych za pomocą curve_fit
# params, covariance = curve_fit(model, x_data, y_data, p0=initial_guess)

# # Pobieramy optymalne wartości parametrów
# A_optimal, T_optimal = params

# # Tworzymy punkty na krzywej dopasowania
# x_fit = np.linspace(min(x_data), max(x_data), 1000)
# y_fit = model(x_fit, A_optimal, T_optimal)

# # Rysujemy wykres z wykorzystaniem seaborn
# plt.figure(figsize=(10, 6))
# sns.scatterplot(x=x_data, y=y_data, label='Data', s=100)
# plt.plot(x_fit, y_fit, label=f'Fit: A={A_optimal:.2f}, T={T_optimal:.2f}', color='red')
# plt.xlabel('x')
# plt.ylabel('y')
# plt.title('Data and Fit')
# plt.legend()
# plt.show()