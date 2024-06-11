// Basic Data Verification
// Query all listings owned by hosts
MATCH (h:Host)-[:HAS_HOST]->(l:Listing) RETURN l, h LIMIT 20

// Query all listings with their calendar records
MATCH (l:Listing)-[:HAS_CALENDAR]->(c:Calendar) RETURN l, c LIMIT 20

// Query all listings with their review scores
MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore) RETURN l, r LIMIT 20

// Query all listings with their amenities
MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity) RETURN l, a LIMIT 20

// Query all listings with their geographic locations
MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location) RETURN l, loc LIMIT 20

// Query all hosts with their geographic locations
MATCH (h:Host)-[:LIVE_IN]->(loc:Location) RETURN h, loc LIMIT 20

// Trend Analysis
// Query number of listings by host
MATCH (h:Host)-[:HAS_HOST]->(l:Listing)
RETURN h.host_name, COUNT(l) AS listing_count
ORDER BY listing_count DESC LIMIT 20

// Query number of listings by location
MATCH (loc:Location)<-[:LOCATED_IN]-(l:Listing)
RETURN loc.neighbourhood, COUNT(l) AS listing_count
ORDER BY listing_count DESC LIMIT 20

// Query listings with review scores above 4.5
MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
RETURN l, r LIMIT 20

// Average review score by host
MATCH (h:Host)-[:HAS_HOST]->(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN h.host_name, AVG(r.review_scores_rating) AS avg_rating
ORDER BY avg_rating DESC LIMIT 20

// Average review score by location
MATCH (loc:Location)<-[:LOCATED_IN]-(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN loc.neighbourhood, AVG(r.review_scores_rating) AS avg_rating
ORDER BY avg_rating DESC LIMIT 20

// Query listings with specific amenities (e.g., Wifi)
MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
WHERE a.amenity_name = "Wifi"
RETURN l, a LIMIT 20

// Advanced Graph Analysis
// Visualize listings with high scores and their hosts
MATCH (l:Listing)-[:HAS_HOST]->(h:Host), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
RETURN l, h, r LIMIT 20

// Visualize all listings, their hosts, and scores
MATCH (l:Listing)-[:HAS_HOST]->(h:Host), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN l, h, r LIMIT 20

// Visualize all listings and their amenities
MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
RETURN l, a LIMIT 20

// Visualize listings and their hosts by specific location (e.g., Downtown)
MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location), (l)-[:HAS_HOST]->(h:Host)
WHERE loc.neighbourhood = "Downtown"
RETURN l, loc, h LIMIT 20

// Query high-scored listings and all their relationships
MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
MATCH (l)-[rel]-(other)
RETURN l, r, rel, other LIMIT 20

// Visualize all hosts, their listings, and locations
MATCH (h:Host)-[:LOCATED_IN]->(loc:Location), (h)-[:HAS_HOST]->(l:Listing)
RETURN h, loc, l LIMIT 20
