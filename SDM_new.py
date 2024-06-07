from neo4j import GraphDatabase
from neo4j.exceptions import AuthError, ServiceUnavailable

# Set the database URI, username, and password
uri = "bolt://localhost:7687"
user = "neo4j"
password = "12345678"

# Create the database driver
driver = GraphDatabase.driver(uri, auth=(user, password))

# Define a function to run a query
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

# Define LOAD CSV query statement
load_csv_query = """
LOAD CSV WITH HEADERS FROM 'file:///cleaned_merged_listings_calendar1_.csv' AS row
WITH row, split(replace(replace(row.amenities, '[', ''), ']', ''), ',') AS amenities

// Create Location node
MERGE (loc:Location {
    neighbourhood: CASE WHEN row.neighbourhood IS NOT NULL THEN row.neighbourhood ELSE 'Unknown' END,
    neighbourhood_cleansed: CASE WHEN row.neighbourhood_cleansed IS NOT NULL THEN row.neighbourhood_cleansed ELSE 'Unknown' END,
    neighbourhood_group_cleansed: CASE WHEN row.neighbourhood_group_cleansed IS NOT NULL THEN row.neighbourhood_group_cleansed ELSE 'Unknown' END,
    latitude: CASE WHEN row.latitude IS NOT NULL THEN toFloat(row.latitude) ELSE null END,
    longitude: CASE WHEN row.longitude IS NOT NULL THEN toFloat(row.longitude) ELSE null END
})

// Create Listing node and establish relationships
MERGE (l:Listing {id: toInteger(row.id)})
ON CREATE SET
    l.listing_url = row.listing_url,
    l.name = row.name,
    l.description = row.description,
    l.neighborhood_overview = row.neighborhood_overview,
    l.picture_url = row.picture_url,
    l.instant_bookable = row.instant_bookable,
    l.license = row.license,
    l.property_type = row.property_type,
    l.room_type = row.room_type,
    l.accommodates = toInteger(row.accommodates),
    l.bathrooms_text = row.bathrooms_text,
    l.bedrooms = toInteger(row.bedrooms),
    l.beds = toInteger(row.beds),
    l.latitude = CASE WHEN row.latitude IS NOT NULL THEN toFloat(row.latitude) ELSE null END,
    l.longitude = CASE WHEN row.longitude IS NOT NULL THEN toFloat(row.longitude) ELSE null END
MERGE (l)-[:LOCATED_IN]->(loc)

// Create Host node and establish relationships
MERGE (h:Host {host_id: toInteger(row.host_id)})
ON CREATE SET
    h.host_name = row.host_name,
    h.host_since = row.host_since,
    h.host_location = row.host_location,
    h.host_about = row.host_about,
    h.host_response_time = row.host_response_time,
    h.host_response_rate = row.host_response_rate,
    h.host_acceptance_rate = row.host_acceptance_rate,
    h.host_is_superhost = row.host_is_superhost,
    h.host_thumbnail_url = row.host_thumbnail_url,
    h.host_picture_url = row.host_picture_url,
    h.host_neighbourhood = row.host_neighbourhood,
    h.host_listings_count = toInteger(row.host_listings_count),
    h.host_total_listings_count = toInteger(row.host_total_listings_count),
    h.host_verifications = row.host_verifications,
    h.host_has_profile_pic = row.host_has_profile_pic,
    h.host_identity_verified = row.host_identity_verified
MERGE (h)-[:HAS_HOST]->(l)
MERGE (h)-[:LOCATED_IN]->(loc)

// Create Calendar node and establish relationships
MERGE (c:Calendar {listing_id: toInteger(row.listing_id), date: row.date})
ON CREATE SET
    c.available = row.available,
    c.price = row.price,
    c.adjusted_price = row.adjusted_price,
    c.minimum_nights = toInteger(row.minimum_nights),
    c.maximum_nights = toInteger(row.maximum_nights)
MERGE (l)-[:HAS_CALENDAR]->(c)

// Create ReviewScore node and establish relationships
MERGE (r:ReviewScore {listing_id: toInteger(row.id)})
ON CREATE SET
    r.review_scores_rating = toFloat(row.review_scores_rating),
    r.review_scores_accuracy = toFloat(row.review_scores_accuracy),
    r.review_scores_cleanliness = toFloat(row.review_scores_cleanliness),
    r.review_scores_checkin = toFloat(row.review_scores_checkin),
    r.review_scores_communication = toFloat(row.review_scores_communication),
    r.review_scores_location = toFloat(row.review_scores_location),
    r.review_scores_value = toFloat(row.review_scores_value),
    r.number_of_reviews = toInteger(row.number_of_reviews),
    r.number_of_reviews_ltm = toInteger(row.number_of_reviews_ltm),
    r.number_of_reviews_l30d = toInteger(row.number_of_reviews_l30d),
    r.first_review = row.first_review,
    r.last_review = row.last_review
MERGE (l)-[:HAS_REVIEW_SCORE]->(r)

// Create Amenity node and establish relationships
WITH l, amenities
UNWIND amenities AS amenity
MERGE (a:Amenity {amenity_name: trim(amenity)})
MERGE (l)-[:HAS_AMENITY]->(a)
RETURN COUNT(*) AS total_rows
"""

# Execute LOAD CSV query
result = run_query(load_csv_query)

# Print the result
if result:
    for record in result:
        print(f"Total rows processed: {record['total_rows']}")
else:
    print("No results returned from the query.")

# Close the driver
driver.close()
