import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load Data
df = pd.read_csv('sales_data.csv', parse_dates=['Date'])

# Clean Data
df.dropna(inplace=True)
df['Sales'] = pd.to_numeric(df['Sales'], errors='coerce')
df = df[df['Sales'] > 0]

# Add Time Columns
df['Month'] = df['Date'].dt.to_period('M')
df['Year'] = df['Date'].dt.year

# ----- Analysis -----

# 1. Total Sales by Category
category_sales = df.groupby('Category')['Sales'].sum().sort_values(ascending=False)

# 2. Top 5 Products by Sales
top_products = df.groupby('Product')['Sales'].sum().sort_values(ascending=False).head(5)

# 3. Monthly Sales Trend
monthly_sales = df.groupby('Month')['Sales'].sum()

# 4. Revenue by Country
country_sales = df.groupby('Country')['Sales'].sum().sort_values(ascending=False)

# ----- Visualizations -----

# Bar Chart: Sales by Category
plt.figure(figsize=(8,5))
sns.barplot(x=category_sales.index, y=category_sales.values)
plt.title('Sales by Category')
plt.ylabel('Total Sales')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Line Chart: Monthly Sales Trend
plt.figure(figsize=(10,5))
monthly_sales.plot(marker='o')
plt.title('Monthly Sales Trend')
plt.ylabel('Sales')
plt.xlabel('Month')
plt.grid(True)
plt.tight_layout()
plt.show()

# Pie Chart: Revenue by Country (Top 5)
top_countries = country_sales.head(5)
plt.figure(figsize=(6,6))
top_countries.plot(kind='pie', autopct='%1.1f%%')
plt.title('Revenue Share by Country (Top 5)')
plt.ylabel('')
plt.tight_layout()
plt.show()
