# SDM-Joint-Project

## Overview
The SDM-Joint-Project is designed to leverage Neo4j graph database technologies to manage and analyze property-related data effectively. This project aims to provide advanced analytics for price prediction and property management insights, particularly tailored for Bed and Breakfast owners in the Catalonia area.

## Repository Contents
- `initialize_neo4j_database.py` - Python script to initialize the Neo4j database with the necessary schema and data.
- `bnb_insight_queries.cypher` - Contains Cypher queries for extracting insights from the data.
- `sdm_preprocessing.ipynb` - Jupyter Notebook for preprocessing data used in the project.
- `calendar1.csv` - Sample data file representing calendar data for listings.

## Getting Started
### Prerequisites
- Neo4j (Preferably the latest version)
- Python 3.8+
- Jupyter Notebook or an environment to run .ipynb files (like Google Colab)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/SDM-Joint-Project.git
   cd SDM-Joint-Project
   
2. **Set up the Neo4j Database:**
   Ensure Neo4j is installed and running on your system.
   Run the initialize_neo4j_database.py to set up the database schema and load initial data.
   
1. **Data Preprocessing：**
   Open the sdm_preprocessing.ipynb notebook in Jupyter or Colab and execute the cells to preprocess the data.

## Relational Graph

https://drive.google.com/file/d/14Wo7hFK97nkzSbsxl63ZpiCw-tWWjaTI/view?usp=sharing
<img width="728" alt="graph" src="https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/92e0dc05-debe-4070-b4b4-b3e41173bb45">



## Query Result Examples

![image](graphs/q3.jpg)
![image](graphs/r2.jpg)



## Data Pipeline
![image](graphs/data_pipeline.jpg)
