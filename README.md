# SDM-Joint-Project
SDM Part of Joint Project

更新一下：
这里我重新分析了calendar和listings的csv，因为前者的数据量太大好几百MB，所以我只抽取了20000行

数据来源airbnb：https://insideairbnb.com/get-the-data/

## 数据预处理：

Python的Pandas进行选择calendar的前20000行数据和listings合并，共同属性列是id，并将其保存到一个新的CSV文件中。

进行数据清洗与处理,涉及到处理一些特定的列（比如去掉货币符号等），代码在这里:
https://colab.research.google.com/drive/1FENHdgKKFWHP-ivmFYpZIaiQI68OBrXX?usp=sharing

新的数据集在这里：
https://drive.google.com/file/d/1sHjZO93XUdtk2ZhCNDmZvj2GElqXdd_j/view?usp=sharing

然后用python脚本将csv导入到neo4j，这中间需要定义节点，属性，关系：

最后导入进去的总行数统计Total rows processed: 713835

## 属性图设计


### 节点:

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

### 关键属性：
1. Listing (房源)

关键属性：id（唯一标识符）、name（房源名称）、property_type（房产类型）、room_type（房间类型）、price（从Calendar节点引用查询）

原因：id是数据库操作的基础；name、property_type和room_type是用户常关心的内容；价格是决策的关键因素，尽管它存储在Calendar节点中，但在展示房源信息时经常需要。

2. Host (房东)

关键属性：host_id（唯一标识符）、host_name（名字）、host_since（开始日期）、host_is_superhost（是否超级房东）

原因：标识、人名用于显示和识别；开始日期和超级房东状态对于评估房东经验和信誉度很重要。

3. Calendar (日历记录)

关键属性：listing_id、date、price、available（是否可用）

原因：这些属性对于决定房源的可预订状态和价格至关重要。

4. ReviewScore (评分)

关键属性：listing_id、review_scores_rating（总评分）

原因：评分是房源吸引力的重要指标，常用于排序和筛选。

5. Location (地理位置)
    
关键属性：latitude、longitude、neighbourhood

原因：位置是房源搜索和选择中的一个主要因素。

6. Amenity (设施)

关键属性：amenity_detail

原因：设施类型是描述房源特色的重要方面。

### 关系
1.HAS_HOST:  Host-> Listing

房东拥有一个房源。（这个关系名字也可以改为OWN等表示拥有）

2.HAS_CALENDAR: Listing -> Calendar

一个房源有多个日历记录。

3.HAS_SCORE: Listing -> ReviewScore

一个房源有多个评分记录。

4.LOCATED_IN: Listing -> Location

一个房源位于一个地理位置。

5.LIVE_IN: Host -> Location

一个房东住在一个地方。

6.HAS_AMENITY: Listing -> Amenity

一个房源有多个设施。



## 关系图（需要用visio或者draw.io重新画一下,并且标清楚属性）

https://drive.google.com/file/d/1RF15cszjf1HAn04WTAhPwIcq4ZdgjXWz/view?usp=sharing（请用draw.io修改这个图）
![1717856367033](https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/c460d957-2eeb-444c-80fc-9c2a72b8cf96)

这是初稿
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


MATCH (h:Host)-[:LIVE_IN]->(loc:Location)
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

### 推荐功能（全部可查）：

1.基于距离的推荐：

给房东推荐同一天内，与它的房子距离500米以内且大于50米的其他房源，返回二者的价格与设施，进行对比
，以便于房东调整价格：

// 查找距离500米以内且大于50米的房源
MATCH (l1:Listing)-[:LOCATED_IN]->(loc1:Location), (l2:Listing)-[:LOCATED_IN]->(loc2:Location)
WHERE l1.id <> l2.id
WITH l1, l2, point({latitude: loc1.latitude, longitude: loc1.longitude}) AS p1, point({latitude: loc2.latitude, longitude: loc2.longitude}) AS p2
WITH l1, l2, point.distance(p1, p2) AS dist
WHERE dist < 500 AND dist > 50

// 查找2024年4月5日的价格
MATCH (l1)-[:HAS_CALENDAR]->(c1:Calendar), (l2)-[:HAS_CALENDAR]->(c2:Calendar)
WHERE c1.date = '2024-04-05' AND c2.date = '2024-04-05'

// 获取设施信息
MATCH (l1)-[:HAS_AMENITY]->(a1:Amenity), (l2)-[:HAS_AMENITY]->(a2:Amenity)
RETURN l1.id AS sourceListing, l1.name AS sourceListingName, COLLECT(a1.amenity_detail) AS sourceListingAmenities, 
       l2.id AS recommendedListing, l2.name AS recommendedListingName, COLLECT(a2.amenity_detail) AS recommendedListingAmenities, 
       c1.price AS sourceListingPrice, c2.price AS recommendedListingPrice, dist
ORDER BY dist
LIMIT 100;


2.基于评分的推荐

通过相似评分推荐其他房源。给房东推荐同一天内，与它的房子评分差距很小的其他房源，返回二者的价格与设施以及所在的区域，进行对比，以便于房东调整价格：

// 基于评分的推荐，查找评分差距在0.2以内的房源
MATCH (l1:Listing)-[:HAS_SCORE]->(r1:ReviewScore), (l2:Listing)-[:HAS_SCORE]->(r2:ReviewScore)
WHERE l1.id <> l2.id
WITH l1, l2, ABS(r1.review_scores_rating - r2.review_scores_rating) AS scoreDiff
WHERE scoreDiff < 0.2 // 评分差距在0.2以内

// 查找2024年4月5日的价格
MATCH (l1)-[:HAS_CALENDAR]->(c1:Calendar), (l2)-[:HAS_CALENDAR]->(c2:Calendar)
WHERE c1.date = '2024-04-05' AND c2.date = '2024-04-05'

// 获取酒店的设施
MATCH (l1)-[:HAS_AMENITY]->(a1:Amenity), (l2)-[:HAS_AMENITY]->(a2:Amenity)

// 获取neighbourhood_cleansed
MATCH (l1)-[:LOCATED_IN]->(loc1:Location), (l2)-[:LOCATED_IN]->(loc2:Location)
WITH l1, l2, loc1.neighbourhood_cleansed AS sourceNeighbourhood, loc2.neighbourhood_cleansed AS recommendedNeighbourhood,
     scoreDiff, c1.price AS sourceListingPrice, c2.price AS recommendedListingPrice,
     collect(DISTINCT a1.amenity_detail) AS sourceAmenities, collect(DISTINCT a2.amenity_detail) AS recommendedAmenities

RETURN l1.id AS sourceListing, l1.name AS sourceListingName, sourceNeighbourhood,
       l2.id AS recommendedListing, l2.name AS recommendedListingName, recommendedNeighbourhood,
       scoreDiff, sourceListingPrice, recommendedListingPrice, sourceAmenities, recommendedAmenities
ORDER BY scoreDiff
LIMIT 10;


3.基于设施的推荐

通过计算房源设施的相似性推荐其他房源。给房东推荐同一天内，与它的房子设施差不多的其他房源，返回二者的价格与设施以及所在的区域，进行对比，以便于房东调整价格：

// 查找共享设施差不多的房源对
MATCH (l1:Listing)-[:HAS_AMENITY]->(a:Amenity)<-[:HAS_AMENITY]-(l2:Listing)
WHERE l1.id <> l2.id
WITH l1, l2, COUNT(a) AS sharedAmenities
ORDER BY sharedAmenities DESC
LIMIT 10

// 查找2024年4月5日的价格
MATCH (l1)-[:HAS_CALENDAR]->(c1:Calendar), (l2)-[:HAS_CALENDAR]->(c2:Calendar)
WHERE c1.date = '2024-04-05' AND c2.date = '2024-04-05'

// 获取酒店的设施
MATCH (l1)-[:HAS_AMENITY]->(a1:Amenity), (l2)-[:HAS_AMENITY]->(a2:Amenity)

// 获取neighbourhood_cleansed
MATCH (l1)-[:LOCATED_IN]->(loc1:Location), (l2)-[:LOCATED_IN]->(loc2:Location)
WITH l1, l2, loc1.neighbourhood_cleansed AS sourceNeighbourhood, loc2.neighbourhood_cleansed AS recommendedNeighbourhood,
     sharedAmenities, c1.price AS sourceListingPrice, c2.price AS recommendedListingPrice,
     collect(DISTINCT a1.amenity_detail) AS sourceAmenities, collect(DISTINCT a2.amenity_detail) AS recommendedAmenities

RETURN l1.id AS sourceListing, l1.name AS sourceListingName, sourceNeighbourhood,
       l2.id AS recommendedListing, l2.name AS recommendedListingName, recommendedNeighbourhood,
       sharedAmenities, sourceListingPrice, recommendedListingPrice, sourceAmenities, recommendedAmenities
ORDER BY sharedAmenities DESC
LIMIT 10;
![image](https://github.com/woshimajintao/SDM-Joint-Project/assets/48515469/f65ec73d-872b-479b-bb05-710a30e90e2a)


