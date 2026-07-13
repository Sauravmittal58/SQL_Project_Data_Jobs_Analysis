import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker

plt.rcParams.update({
    "figure.facecolor": "white",
    "axes.facecolor": "white",
    "font.size": 11,
    "axes.edgecolor": "#333333",
    "axes.labelcolor": "#222222",
    "text.color": "#222222",
    "xtick.color": "#333333",
    "ytick.color": "#333333",
})

ACCENT = "#1f77b4"
ACCENT2 = "#ff7f0e"

# ---------- 1. Top 10 highest-paying remote Data Analyst jobs ----------
df1 = pd.read_csv("data/1_top_paying_jobs.csv")
df1 = df1.sort_values("salary_year_avg", ascending=True)
labels = [f"{t[:35]}\n({c})" for t, c in zip(df1.job_title, df1.company_name)]

fig, ax = plt.subplots(figsize=(10, 6))
bars = ax.barh(labels, df1.salary_year_avg, color=ACCENT)
ax.set_xlabel("Average Yearly Salary (USD)")
ax.set_title("Top 10 Highest-Paying Remote Data Analyst Jobs (2023)", fontsize=13, fontweight="bold")
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
for bar, val in zip(bars, df1.salary_year_avg):
    ax.text(val + 5000, bar.get_y() + bar.get_height()/2, f"${val:,.0f}", va="center", fontsize=9)
plt.tight_layout()
plt.savefig("images/1_top_paying_jobs.png", dpi=150)
plt.close()

# ---------- 2. Skill counts among top 10 highest-paying jobs ----------
df2 = pd.read_csv("data/2_top_paying_roles.csv")
skill_counts = df2["skills"].value_counts().head(10).sort_values(ascending=True)

fig, ax = plt.subplots(figsize=(9, 6))
bars = ax.barh(skill_counts.index, skill_counts.values, color=ACCENT2)
ax.set_xlabel("Number of Top-10 Job Postings Requiring the Skill")
ax.set_title("Most Requested Skills Among the Top 10 Highest-Paying\nData Analyst Jobs", fontsize=13, fontweight="bold")
for bar, val in zip(bars, skill_counts.values):
    ax.text(val + 0.05, bar.get_y() + bar.get_height()/2, str(val), va="center", fontsize=9)
plt.tight_layout()
plt.savefig("images/2_top_paying_job_skills.png", dpi=150)
plt.close()

# ---------- 3. Top 5 in-demand skills ----------
df3 = pd.read_csv("data/3_top_demanded_skills.csv")
df3 = df3.sort_values("demand_count", ascending=True)

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.barh(df3.skills, df3.demand_count, color=ACCENT)
ax.set_xlabel("Number of Job Postings Requesting the Skill")
ax.set_title("Top 5 In-Demand Skills for Data Analysts\n(All Remote Postings)", fontsize=13, fontweight="bold")
for bar, val in zip(bars, df3.demand_count):
    ax.text(val + 50, bar.get_y() + bar.get_height()/2, f"{val:,}", va="center", fontsize=9)
plt.tight_layout()
plt.savefig("images/3_top_demanded_skills.png", dpi=150)
plt.close()

# ---------- 4. Top 25 highest-paying skills ----------
df4 = pd.read_csv("data/4_top_paying_skills.csv").sort_values("avg_salary", ascending=True)

fig, ax = plt.subplots(figsize=(9, 9))
bars = ax.barh(df4.skills, df4.avg_salary, color=ACCENT2)
ax.set_xlabel("Average Yearly Salary (USD)")
ax.set_title("Top 25 Highest-Paying Skills for Data Analysts", fontsize=13, fontweight="bold")
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
plt.tight_layout()
plt.savefig("images/4_top_paying_skills.png", dpi=150)
plt.close()

# ---------- 5. Optimal skills: demand vs salary scatter ----------
df5 = pd.read_csv("data/5_optimal_skills.csv")
df5 = df5.drop_duplicates(subset="skills")

fig, ax = plt.subplots(figsize=(10, 7))
ax.scatter(df5.demand_count, df5.average_sal, s=90, color=ACCENT, edgecolor="white", linewidth=0.8, zorder=3)
for _, row in df5.iterrows():
    ax.annotate(row.skills, (row.demand_count, row.average_sal),
                xytext=(6, 4), textcoords="offset points", fontsize=9)
ax.set_xlabel("Demand Count (number of remote postings)")
ax.set_ylabel("Average Yearly Salary (USD)")
ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
ax.set_title("Optimal Skills for Data Analysts: High Demand vs. High Salary", fontsize=13, fontweight="bold")
ax.grid(True, linestyle="--", alpha=0.4, zorder=0)
plt.tight_layout()
plt.savefig("images/5_optimal_skills.png", dpi=150)
plt.close()

print("All charts generated.")
