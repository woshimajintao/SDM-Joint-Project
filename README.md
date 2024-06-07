# SDM-Joint-Project
SDM Part of Joint Project

更新一下：
这里我重新分析了calendar和listings的csv，因为前者的数据量太大好几百MB，所以我只抽取了20000行

## 数据预处理：

Python的Pandas进行选择calendar的前20000行数据和listings合并，共同属性列是id，并将其保存到一个新的CSV文件中。

进行数据清洗与处理,涉及到处理一些特定的列，代码在这里:
https://colab.research.google.com/drive/1FENHdgKKFWHP-ivmFYpZIaiQI68OBrXX?usp=sharing

新的数据集在这里：
https://drive.google.com/file/d/1-A0-D0aZmVnyupvOqK-yi5A2L1LAlVmS/view?usp=share_link

然后用python脚本将csv导入到neo4j，这中间需要定义节点，属性，关系：

最后导入进去的总行数统计Total rows processed: 713835

## 属性图设计


### 节点和属性:

下面是节点类型及其属性：

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

### 关系
1.HAS_HOST:  Host-> Listing

房东拥有一个房源。（这个关系名字也可以改为OWN等表示拥有）

2.HAS_CALENDAR: Listing -> Calendar

一个房源有多个日历记录。

3.HAS_REVIEW_SCORE: Listing -> ReviewScore

一个房源有多个评分记录。

4.LOCATED_IN: Listing -> Location

一个房源位于一个地理位置。

5.LOCATED_IN: Host -> Location

一个房东位于一个地理位置。（这里也可以改为LIVE_IN）

6.HAS_AMENITY: Listing -> Amenity

一个房源有多个设施。



## 关系图（需要用visio或者draw.io重新画一下,并且标清楚属性）
![image](https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/245ddabb-0dd5-42f2-9984-b345fcb0c348)



## 查询语句：
下面这些查询涵盖了基本的数据验证、趋势分析和高级图分析。这里还可以写更多更复杂的。这些都能查到结果，我只放了其中几张图，后面更多的查询结果的图可以加在report和PPT或者网页里面。


### 基本数据验证
查询所有房东的房源：


MATCH (h:Host)-[:HAS_HOST]->(l:Listing) RETURN l, h LIMIT 20


查询所有房源及其日历记录：


MATCH (l:Listing)-[:HAS_CALENDAR]->(c:Calendar)
RETURN l, c
LIMIT 20

查询所有房源及其评分：


MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN l, r
LIMIT 20

查询所有房源及其设施：


MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
RETURN l, a
LIMIT 20

查询所有房源及其地理位置：


MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location)
RETURN l, loc
LIMIT 20

查询所有房东及其地理位置：


MATCH (h:Host)-[:LOCATED_IN]->(loc:Location)
RETURN h, loc
LIMIT 20
### 趋势分析
按房东查询房源数量：


MATCH (h:Host)-[:HAS_HOST]->(l:Listing) RETURN h.host_name, COUNT(l) AS listing_count ORDER BY listing_count DESC LIMIT 20


按位置查询房源数量：


MATCH (loc:Location)<-[:LOCATED_IN]-(l:Listing)
RETURN loc.neighbourhood, COUNT(l) AS listing_count
ORDER BY listing_count DESC
LIMIT 20

查询特定评分高于4.5的房源：


MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
RETURN l, r
LIMIT 20

按房东查询平均评分：



MATCH (h:Host)-[:HAS_HOST]->(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore) RETURN h.host_name, AVG(r.review_scores_rating) AS avg_rating ORDER BY avg_rating DESC LIMIT 20


按位置查询平均评分：


MATCH (loc:Location)<-[:LOCATED_IN]-(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN loc.neighbourhood, AVG(r.review_scores_rating) AS avg_rating
ORDER BY avg_rating DESC
LIMIT 20

查询特定设施的房源：


MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
WHERE a.amenity_name = "Wifi"
RETURN l, a
LIMIT 20

### 高级图分析
可视化评分高于4.5的房源及其房东：


MATCH (l:Listing)-[:HAS_HOST]->(h:Host), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
RETURN l, h, r
LIMIT 20

可视化所有房源及其房东、评分：


MATCH (l:Listing)-[:HAS_HOST]->(h:Host), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN l, h, r
LIMIT 20

可视化所有房源及其设施：


MATCH (l:Listing)-[:HAS_AMENITY]->(a:Amenity)
RETURN l, a
LIMIT 20

可视化特定位置的房源及其房东：


MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location), (l)-[:HAS_HOST]->(h:Host)
WHERE loc.neighbourhood = "Downtown"
RETURN l, loc, h
LIMIT 20

查询评分高的房源及其所有关系：


MATCH (l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
WHERE r.review_scores_rating > 4.5
MATCH (l)-[rel]-(other)
RETURN l, r, rel, other
LIMIT 20

可视化所有房东及其房源和位置：


MATCH (h:Host)-[:LOCATED_IN]->(loc:Location), (h)-[:HAS_HOST]->(l:Listing) RETURN h, loc, l LIMIT 20

![image](https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/9a3740c3-98fe-41f8-85c2-13c84dee6c1c)
![image](https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/13d5f01d-d20f-4f4d-8a25-8be431f1a0ce)
![image](https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/74737dd9-4419-4cc5-ae3f-d6708cd06d3a)

### 数据验证
验证是否所有房源都有房东：


MATCH (l:Listing) WHERE NOT (l)<-[:HAS_HOST]-() RETURN l LIMIT 20


验证是否所有房源都有评分：


MATCH (l:Listing)
WHERE NOT (l)-[:HAS_REVIEW_SCORE]->()
RETURN l
LIMIT 20

验证是否所有房源都有日历记录：


MATCH (l:Listing)
WHERE NOT (l)-[:HAS_CALENDAR]->()
RETURN l
LIMIT 20

验证是否所有房东都有位置：


MATCH (h:Host)
WHERE NOT (h)-[:LOCATED_IN]->()
RETURN h
LIMIT 20

进一步分析查询所有房东及其所有房源的平均评分：


MATCH (h:Host)-[:HAS_HOST]->(l:Listing)-[:HAS_REVIEW_SCORE]->(r:ReviewScore) RETURN h.host_name, AVG(r.review_scores_rating) AS avg_rating, COUNT(l) AS listing_count ORDER BY avg_rating DESC LIMIT 20


查询所有房东的响应率和接受率：


MATCH (h:Host)
RETURN h.host_name, h.host_response_rate, h.host_acceptance_rate
ORDER BY h.host_response_rate DESC
LIMIT 20

查询所有房源及其地理位置和评分：


MATCH (l:Listing)-[:LOCATED_IN]->(loc:Location), (l)-[:HAS_REVIEW_SCORE]->(r:ReviewScore)
RETURN l, loc, r
LIMIT 20





