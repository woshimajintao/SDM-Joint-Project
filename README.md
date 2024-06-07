# SDM-Joint-Project
SDM Part of Joint Project
更新一下：
这里我分析了calendar和listings的csv，因为数据量太大，所以我只抽取了前20000行，然后建立了属性图

## 使用head命令选择前3000行数据：

在Mac的命令行中使用以下命令选择前10000行数据，并将其保存到一个新的CSV文件中。

head -n 3000 "/System/Volumes/Data/Users/jintaoma/Desktop/UPC/BDM/project/calendar.csv" > "/System/Volumes/Data/Users/jintaoma/Desktop/UPC/BDM/project/calendar_first_3000.csv"



## 属性图设计


###节点类型

节点类型及其属性

1.Listing: 房源

属性:
id: INTEGER
listing_url: STRING
name: STRING
description: STRING
neighborhood_overview: STRING
picture_url: STRING
instant_bookable: BOOLEAN
license: STRING
property_type: STRING
room_type: STRING
accommodates: INTEGER
bathrooms_text: STRING
bedrooms: INTEGER
beds: INTEGER
latitude: FLOAT
longitude: FLOAT

2.Host: 房东

属性:
host_id: INTEGER
host_name: STRING
host_since: DATE
host_location: STRING
host_about: STRING
host_response_time: STRING
host_response_rate: STRING
host_acceptance_rate: STRING
host_is_superhost: BOOLEAN
host_thumbnail_url: STRING
host_picture_url: STRING
host_neighbourhood: STRING
host_listings_count: INTEGER
host_total_listings_count: INTEGER
host_verifications: STRING
host_has_profile_pic: BOOLEAN
host_identity_verified: BOOLEAN

3.Calendar: 日历记录

属性:
listing_id: INTEGER
date: DATE
available: BOOLEAN
price: STRING
adjusted_price: STRING
minimum_nights: INTEGER
maximum_nights: INTEGER

4.ReviewScore: 评分

属性:
listing_id: INTEGER
review_scores_rating: FLOAT
review_scores_accuracy: FLOAT
review_scores_cleanliness: FLOAT
review_scores_checkin: FLOAT
review_scores_communication: FLOAT
review_scores_location: FLOAT
review_scores_value: FLOAT
number_of_reviews: INTEGER
number_of_reviews_ltm: INTEGER
number_of_reviews_l30d: INTEGER
first_review: DATE
last_review: DATE

5.Location: 地理位置

属性:
neighbourhood: STRING
neighbourhood_cleansed: STRING
neighbourhood_group_cleansed: STRING
latitude: FLOAT
longitude: FLOAT

6.Amenity: 设施

属性:
amenity_name: STRING

###关系类型
1.HAS_HOST: Listing -> Host

一个房源由一个房东拥有。
2.HAS_CALENDAR: Listing -> Calendar

一个房源有多个日历记录。
3.HAS_REVIEW_SCORE: Listing -> ReviewScore

一个房源有多个评分记录。
4.LOCATED_IN: Listing -> Location

一个房源位于一个地理位置。
5.LOCATED_IN: Host -> Location

一个房东位于一个地理位置。
6.HAS_AMENITY: Listing -> Amenity

一个房源有多个设施。



## 关系图
![image](https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/fe5acf3f-1d49-444a-8900-f10c58028c24)



## 查询语句：
下面这些查询涵盖了基本的数据验证、趋势分析和高级图分析。我们还可以写更多更复杂的。

###基本数据验证
查询所有房源及其房东


MATCH (l:Listing)-[:HAS_HOST]->(h:Host)
RETURN l, h
LIMIT 20
查询所有房源及其日历记录


MATCH (l:Listing)-[:HAS_CALENDAR]->(c:Calendar)
RETURN l, c
LIMIT 20
查询所有房源及其评分


MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN l, r
LIMIT 20
查询所有房源及其设施


MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
RETURN l, a
LIMIT 20
查询所有房源及其地理位置


MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location)
RETURN l, loc
LIMIT 20
查询所有房东及其地理位置


MATCH (h:Host)-[:LOCATED_IN]->(loc:Location)
RETURN h, loc
LIMIT 20
###趋势分析
按房东查询房源数量


MATCH (h:Host)<-[:HAS_HOST]-(l:Listing)
RETURN h.host_name, COUNT(l) AS listing_count
ORDER BY listing_count DESC
LIMIT 20
按位置查询房源数量


MATCH (loc:Location)<-[:LOCATED_IN]-(l:Listing)
RETURN loc.neighbourhood, COUNT(l) AS listing_count
ORDER BY listing_count DESC
LIMIT 20
查询特定评分高于4.5的房源


MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
RETURN l, r
LIMIT 20
按房东查询平均评分



MATCH (h:Host)<-[:HAS_HOST]-(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN h.host_name, AVG(r.review_scores_rating) AS avg_rating
ORDER BY avg_rating DESC
LIMIT 20
按位置查询平均评分


MATCH (loc:Location)<-[:LOCATED_IN]-(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN loc.neighbourhood, AVG(r.review_scores_rating) AS avg_rating
ORDER BY avg_rating DESC
LIMIT 20
查询特定设施的房源


MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
WHERE a.amenity_name = "Wifi"
RETURN l, a
LIMIT 20
###高级图分析
可视化评分高于4.5的房源及其房东


MATCH (l:Listing)-[:HAS_HOST]->(h:Host), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
RETURN l, h, r
LIMIT 20
可视化所有房源及其房东、评分


MATCH (l:Listing)-[:HAS_HOST]->(h:Host), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN l, h, r
LIMIT 20
可视化所有房源及其设施


MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
RETURN l, a
LIMIT 20
可视化特定位置的房源及其房东


MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location), (l)-[:HAS_HOST]->(h:Host)
WHERE loc.neighbourhood = "Downtown"
RETURN l, loc, h
LIMIT 20
查询评分高的房源及其所有关系


MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
MATCH (l)-[rel]-(other)
RETURN l, r, rel, other
LIMIT 20
可视化所有房东及其房源和位置


MATCH (h:Host)-[:LOCATED_IN]->(loc:Location), (h)<-[:HAS_HOST]-(l:Listing)
RETURN h, loc, l
LIMIT 20
###数据验证
验证是否所有房源都有房东


MATCH (l:Listing)
WHERE NOT (l)-[:HAS_HOST]->()
RETURN l
LIMIT 20
验证是否所有房源都有评分


MATCH (l:Listing)
WHERE NOT (l)-[:HAS_REVIEW_SCORE]->()
RETURN l
LIMIT 20
验证是否所有房源都有日历记录


MATCH (l:Listing)
WHERE NOT (l)-[:HAS_CALENDAR]->()
RETURN l
LIMIT 20
验证是否所有房东都有位置


MATCH (h:Host)
WHERE NOT (h)-[:LOCATED_IN]->()
RETURN h
LIMIT 20
进一步分析
查询所有房东及其所有房源的平均评分


MATCH (h:Host)<-[:HAS_HOST]-(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN h.host_name, AVG(r.review_scores_rating) AS avg_rating, COUNT(l) AS listing_count
ORDER BY avg_rating DESC
LIMIT 20
查询所有房东的响应率和接受率


MATCH (h:Host)
RETURN h.host_name, h.host_response_rate, h.host_acceptance_rate
ORDER BY h.host_response_rate DESC
LIMIT 20

查询所有房源及其地理位置和评分


MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN l, loc, r
LIMIT 20




