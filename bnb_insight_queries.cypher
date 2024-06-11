// Queries：
Air Conditioner：
MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
WHERE a.amenity_detail = 'Air conditioning'
RETURN l, a


// Sagrada Familia：
MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location), (l)-[:HAS_CALENDAR]->(c:Calendar)
WHERE loc.neighbourhood_cleansed = 'la Sagrada Família'
RETURN l, loc, c.price


// Saint Jordi：
MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location)
MATCH (l)-[:HAS_CALENDAR]->(c:Calendar)
WHERE c.date = '2024-04-23'
MATCH (l)-[:HAS_AMENITY]->(a:Amenity)
RETURN l, loc, c.price, a

// High Rating：
MATCH (l:Listing)-[:HAS_SCORE]->(r:ReviewScore) WHERE r.review_scores_rating > 4.5 MATCH (l)-[rel]-(other)RETURN l, r, rel, other LIMIT 20


// Recommandation System：
// Rating：
MATCH (h:Host {host_name: 'Sandra'})-[:OWN]->(l1:Listing)-[:LOCATED_IN]->(loc1:Location)

MATCH (l2:Listing)-[:LOCATED_IN]->(loc2:Location)
WHERE l1.id <> l2.id
AND point.distance(point({latitude: loc1.latitude, longitude: loc1.longitude}), point({latitude: loc2.latitude, longitude:loc2.longitude})) > 200
AND point.distance(point({latitude: loc1.latitude, longitude: loc1.longitude}), point({latitude: loc2.latitude, longitude:loc2.longitude})) <500

// Get the housing rating less than 0.5
MATCH (l1)-[:HAS_SCORE]->(r1:ReviewScore), (l2)-[:HAS_SCORE]->(r2:ReviewScore)
WHERE abs(r1.review_scores_rating - r2.review_scores_rating) < 0.5

// Get Amenity
MATCH (l1)-[:HAS_AMENITY]->(a1:Amenity), (l2)-[:HAS_AMENITY]->(a2:Amenity)

// Get neighbourhood_cleansed
MATCH (l1)-[:LOCATED_IN]->(loc1:Location), (l2)-[:LOCATED_IN]->(loc2:Location)
WITH h, l1, l2, loc1.neighbourhood_cleansed AS sourceNeighbourhood, loc2.neighbourhood_cleansed ASrecommendedNeighbourhood,
c1.price AS sourceListingPrice, c2.price AS recommendedListingPrice,
COLLECT(DISTINCT a1.amenity_detail) AS sourceAmenities, COLLECT(DISTINCT a2.amenity_detail) ASrecommendedAmenities,
r1.review_scores_rating AS sourceRating, r2.review_scores_rating AS recommendedRating,
point.distance(point({latitude: loc1.latitude, longitude: loc1.longitude}), point({latitude: loc2.latitude, longitude:loc2.longitude})) AS distance,
abs(r1.review_scores_rating - r2.review_scores_rating) AS ratingDifference

RETURN h.host_name AS hostName,
l1.id AS sourceListing,
l2.id AS recommendedListing,
sourceListingPrice,
recommendedListingPrice,
distance,
ratingDifference,
l1.name AS sourceListingName,
l2.name AS recommendedListingName,
sourceNeighbourhood,
recommendedNeighbourhood,
sourceAmenities,
recommendedAmenities
ORDER BY ratingDifference, distance
LIMIT 10;


// Similar Amenity：
MATCH (h:Host {host_name: 'Sandra'})-[:OWN]->(l1:Listing)

MATCH (l1)-[:HAS_AMENITY]->(a:Amenity)<-[:HAS_AMENITY]-(l2:Listing)
WHERE l1.id <> l2.id AND l1.id < l2.id
WITH h, l1, l2, COUNT(a) AS sharedAmenities
ORDER BY sharedAmenities DESC
LIMIT 10

// Get the price of 2024 April 23
MATCH (l1)-[:HAS_CALENDAR]->(c1:Calendar), (l2)-[:HAS_CALENDAR]->(c2:Calendar)
WHERE c1.date = '2024-04-23' AND c2.date = '2024-04-23'

// Get Amenity
MATCH (l1)-[:HAS_AMENITY]->(a1:Amenity), (l2)-[:HAS_AMENITY]->(a2:Amenity)

// Get neighbourhood_cleansed
MATCH (l1)-[:LOCATED_IN]->(loc1:Location), (l2)-[:LOCATED_IN]->(loc2:Location)
WITH h, l1, l2, loc1.neighbourhood_cleansed AS sourceNeighbourhood, loc2.neighbourhood_cleansed ASrecommendedNeighbourhood,
sharedAmenities, c1.price AS sourceListingPrice, c2.price AS recommendedListingPrice,
COLLECT(DISTINCT a1.amenity_detail) AS sourceAmenities, COLLECT(DISTINCT a2.amenity_detail) ASrecommendedAmenities

RETURN h.host_name AS hostName,
l1.id AS sourceListing,
l2.id AS recommendedListing,
sharedAmenities,
sourceListingPrice,
recommendedListingPrice,
l1.name AS sourceListingName,
l2.name AS recommendedListingName,
sourceNeighbourhood,
recommendedNeighbourhood,
sourceAmenities,
recommendedAmenities
ORDER BY sharedAmenities DESC
LIMIT 10;

