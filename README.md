# SDM-Joint-Project
SDM Part of Joint Project
这里我只分析了calendar的csv，因为数据量太大，所以我只抽取了前3000行，然后建立了很简单的属性图，我觉得其他巴塞罗那Airbnb的csv也可以一块分析或者建立更复杂的属性图

## 使用head命令选择前3000行数据：

在Mac的命令行中使用以下命令选择前3000行数据，并将其保存到一个新的CSV文件中。
```sh
head -n 3000 "/System/Volumes/Data/Users/jintaoma/Desktop/UPC/BDM/project/calendar.csv" > "/System/Volumes/Data/Users/jintaoma/Desktop/UPC/BDM/project/calendar_first_3000.csv"

---

## 属性图设计

### 节点：
房源（Listing）：表示一个Airbnb房源
属性：listing_id、minimum_nights、maximum_nights

节点：
日期（Date）：表示一个日期。
属性：date

### 关系：
HAS_PRICE_ON：连接一个房源到一个日期，表示该日期的价格和可用性。
属性：price、adjusted_price、available

### 元模型定义：
(Listing)-[HAS_PRICE_ON {price, adjusted_price, available}]->(Date)


(Node)             (Relationship)                   (Node)
[Listing] --[HAS_PRICE_ON {price, adjusted_price, available}]--> [Date]

  属性:              属性:                         属性:
  listing_id         price                         date
  minimum_nights     adjusted_price
  maximum_nights     available

## 图示例：

房源（Listing）节点：用一个圆圈表示，包含 listing_id、minimum_nights 和 maximum_nights 属性。
日期（Date）节点：用一个圆圈表示，包含 date 属性。
HAS_PRICE_ON关系：用一个箭头表示，连接 Listing 节点和 Date 节点，箭头上标注 price、adjusted_price 和 available 属性。

## Relationship Diagram

This diagram shows the relationship between the Listing and Date entities in the database.

```markdown
+-------------------+                         
|    Listing        |                          
|-------------------|                           
| listing_id        |                           
| minimum_nights    |                           
| maximum_nights    |
+-------------------+
      |    
      |    
      | HAS_PRICE_ON {price, adjusted_price, available}
      |
      V
+-------------------+
|       Date        |
|-------------------|
|       date        |
+-------------------+


## 查询语句：
下面这些查询涵盖了基本的数据验证、趋势分析和高级图分析。我们还可以写更多更复杂的。

### 查询导入的数据

1. 查看 Listing 节点的前10行


MATCH (l:Listing)
RETURN l
LIMIT 10;
2. 查看 Date 节点的前10行

MATCH (d:Date)
RETURN d
LIMIT 10;
3. 查看 HAS_PRICE_ON 关系的前10行

MATCH (l:Listing)-[r:HAS_PRICE_ON]->(d:Date)
RETURN l.listing_id, d.date, r.price, r.adjusted_price, r.available
LIMIT 10;

### 分析数据

4. 按日期查询特定日期的可用房源



MATCH (l:Listing)-[r:HAS_PRICE_ON]->(d:Date)
WHERE d.date = '2024-04-01' AND r.available = 't'
RETURN l.listing_id, r.price, r.adjusted_price;
5. 分析某个房源在指定日期范围内的价格趋势

MATCH (l:Listing {listing_id: '360863'})-[r:HAS_PRICE_ON]->(d:Date)
WHERE d.date >= '2024-03-01' AND d.date <= '2024-04-01'
RETURN d.date, r.price, r.adjusted_price
ORDER BY d.date;
6. 计算每个房源在某个日期范围内的平均价格

MATCH (l:Listing)-[r:HAS_PRICE_ON]->(d:Date)
WHERE d.date >= '2024-03-01' AND d.date <= '2024-04-01'
RETURN l.listing_id, AVG(r.price) AS avg_price
ORDER BY avg_price DESC;
7. 查询某个日期范围内所有房源的总收入

MATCH (l:Listing)-[r:HAS_PRICE_ON]->(d:Date)
WHERE d.date >= '2024-03-01' AND d.date <= '2024-04-01'
RETURN SUM(r.price) AS total_revenue;

### 高级分析：

8. 找出在特定日期范围内所有可用房源的最短租期

MATCH (l:Listing)-[r:HAS_PRICE_ON]->(d:Date)
WHERE d.date >= '2024-03-01' AND d.date <= '2024-04-01' AND r.available = 't'
RETURN l.listing_id, l.minimum_nights
ORDER BY l.minimum_nights;
9. 分析房源的可用性分布


MATCH (l:Listing)-[r:HAS_PRICE_ON]->(d:Date)
WHERE d.date >= '2024-03-01' AND d.date <= '2024-04-01'
RETURN r.available, COUNT(r) AS availability_count
ORDER BY availability_count DESC;
10. 找出价格最贵的前5个房源

MATCH (l:Listing)-[r:HAS_PRICE_ON]->(d:Date)
WHERE r.price IS NOT NULL
RETURN l.listing_id, MAX(r.price) AS max_price
ORDER BY max_price DESC
LIMIT 5;

