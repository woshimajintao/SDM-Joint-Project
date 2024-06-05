from neo4j import GraphDatabase
from neo4j.exceptions import AuthError, ServiceUnavailable

# Set the database URI, username, and password
# You can change to yours
uri = "bolt://localhost:7687"
user = "neo4j"
password = "12345678"

# Create the database driver
driver = GraphDatabase.driver(uri, auth=(user, password))

# Define a function to run a query
# You can also add more functions to query
def run_query(query):
    try:
        with driver.session() as session:
            result = session.run(query)
            records = [record for record in result]
            return records
    except AuthError as e:
        print("Authentication failed:", e)
    except ServiceUnavailable as e:
        print("Service unavailable:", e)
    except Exception as e:
        print("An error occurred:", e)
        return []

# Load CSV file and execute a complex MERGE query
load_csv_query = """
LOAD CSV WITH HEADERS FROM 'file:///calendar1.csv' AS row
MERGE (l:Listing {listing_id: row.listing_id})
SET l.minimum_nights = toInteger(row.minimum_nights),
    l.maximum_nights = toInteger(row.maximum_nights)
MERGE (d:Date {date: row.date})
WITH l, d, row, toFloat(substring(row.price, 2)) AS price
MERGE (l)-[r:HAS_PRICE_ON {price: price, available: row.available}]->(d)
SET r.adjusted_price = CASE WHEN row.adjusted_price IS NOT NULL THEN toFloat(row.adjusted_price) ELSE NULL END
RETURN count(*) AS total_rows
"""

# Execute the query
result = run_query(load_csv_query)

# Print the result
if result:
    for record in result:
        print(f"Total rows processed: {record['total_rows']}")

# Close the driver
driver.close()
