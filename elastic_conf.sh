#!/bin/bash -x 

curl -XDELETE localhost:9200/_template/pb_data
curl -XDELETE localhost:9200/_template/pb_data_body
curl -XDELETE localhost:9200/_template/pb_data_url

curl -XPUT localhost:9200/_template/pb_data -d '
{
    "template" : "pb_data*",
    "order" : 0,
    "settings" : {
        "number_of_shards" : 5,
        "number_of_replicas" : 1
    },
    "mappings" : {
        "item" : {
            "dynamic" : false,
            "properties" : {
                "text" : {
                    "type" : "string", 
                    "include_in_all": true,
                    "position_offset_gap" : 100
                },
                "ctx" : {
                        "boost": 0.33,
                    "type" : "string", 
                    "include_in_all": true,
                    "position_offset_gap" : 100
                },
                "urlh" : {
                    "type" : "string", 
                    "include_in_all": false,
                    "index": "not_analyzed"
                },
                "v" : {
                        "type": "long",
                        "include_in_all": false
                },
                "bins" : {
                    "boost": 0.01,
                    "type": "string",
                    "include_in_all": false,
                    "position_offset_gap" : 100
                }                
            },
            "_timestamp" : { "enabled" : true, "path": "last_seen" },
            "_boost" : { "name" : "boost", "null_value" : 1.0 }
        }
    }
}'

curl -XPUT localhost:9200/_template/pb_data_body -d '
{
    "template" : "pb_data_body*",
    "order" : 1
}'
curl -XPUT localhost:9200/_template/pb_data_url -d '
{
    "template" : "pb_data_url*",
    "order" : 1,
    "mappings" : {
        "item" : {
            "properties" : {
                "ctx" : {
                        "boost": 0.05
                }
            }
        }
    }    
}'

curl -XDELETE localhost:9200/_template/pb_url
curl -XPUT localhost:9200/_template/pb_url -d '
{
    "template" : "pb_url*",
    "order" : 0,
    "settings" : {
        "number_of_shards" : 5,
        "number_of_replicas" : 1
    },
    "mappings" : {
        "url" : {
            "dynamic" : false,
            "properties" : {
                "url" : {
                    "type" : "string", 
                    "include_in_all": false,
                    "position_offset_gap" : 100
                }
             },
            "_timestamp" : { "enabled" : true, "path": "first_seen" },
            "_boost" : { "name" : "boost", "null_value" : 1.0 }
        }
    }
}'
curl -XDELETE 'http://localhost:9200/pb_data_phrase_0000/'
curl -XDELETE 'http://localhost:9200/pb_data_title_0000/'
curl -XDELETE 'http://localhost:9200/pb_data_synopsis_0000/'
curl -XDELETE 'http://localhost:9200/pb_data_url_0000/'
curl -XDELETE 'http://localhost:9200/pb_data_body_0000/'
curl -XDELETE 'http://localhost:9200/pb_url_0000/'

curl -XPUT http://localhost:9200/pb_data_phrase_0000/item/1_q -d '{
    "text"     : "youtube", "last_seen":"2012-11-15T14:12:12" }'

curl -XPUT http://localhost:9200/pb_data_title_0000/item/1_t -d '{
    "text"     : "youtube watch 2", "last_seen":"2012-11-15T14:12:12" }'

curl -XPUT http://localhost:9200/pb_data_title_0000/item/1_t -d '{
    "text"     : "youtube watch 2", "last_seen":"2012-11-15T14:12:12" }'

curl -XPUT http://localhost:9200/pb_data_synopsis_0000/item/1_s -d '{
    "text"     : "The Absolute Worst Free Throw Shot In the History of the World", "last_seen":"2012-11-15T14:12:12" }'

curl -XPUT http://localhost:9200/pb_data_url_0000/item/1_u -d '{
    "text"     : "http www youtube com", "last_seen":"2012-11-15T14:12:12" }'

curl -XPUT http://localhost:9200/pb_data_body_0000/item/1_b -d '{
    "text"     : "Sign In\nUpload\n\nSearch\n\n\n\n\n Popular on YouTube\n Music\n Sports\n Gaming\n Movies\n TV Shows\n News\n Spotlight\nCHANNELS FOR YOU\n AlJazeeraEnglish\n WSJDigitalNetwork\n TheNewYorkTimes\n BuzzFeed\n HplusDigitalSeries\n Browse channels\nSign in to add channels to your guide and for great recommendations!\n\nSign In ›\n2:33  \nMan of Steel - Official Trailer #2 [HD]\nby WarnerBrosPictures\nNew trailer for the new Superman movie\nkottke.org\n0:12  \nWCU vs App State- Worst free throw ever\nby wcu62TV\nThe Absolute Worst Free Throw Shot In the History of the World\nBarstool Sports: Boston\n2:40  \nChris Rock - Message for White Voters\nby JimmyKimmelLive\n 9,988,981 views 1 month ago\n1:29  \nRobot(II)\nby AdobeSystems\n 226,956 views 1 month ago\nENTERTAINMENT\n1:06  \nStar Trek Into Darkness - Official Teaser (HD)\n10,362,364 views 1 week ago\n3:35  \nDisagreeing With People\n511,841 views 3 days ago\nMUSIC\n2:20  \nMoses vs Santa Claus. Epic Rap Battles of History Season 2\n7,517,984 views 2 days ago\nADOBE\n1:51  \nClick Here: The State of Online Advertising\n 1,477 views 1 month ago\n1:09  \nBS Detector\n 239,033 views 1 month ago\n0:31  \nBS Detector\n 15,174 views 1 month ago\nFILMS\n2:21  \nPacific Rim Official Trailer\n898,183 views 18 hours ago\n2:20  \nThe Dark Knight Rises Trailer 3: IN LEGO\n221,445 views 1 day ago\n11:08  \nMARIO WARFARE - Part 1\n332,395 views 2 days ago\nEVENSYS\n2\nAbout Press & Blogs Copyright Creators & Partners Advertising Developers\nTerms Privacy Safety Send feedback Try something new! © 2012 YouTube, LLC\nSend feedback", "last_seen":"2012-11-15T14:12:12" }'

curl -XPUT http://localhost:9200/pb_url_0000/item/1 -d '{
    "url"     : "http://www.youtube.com/", "first_seen":"2010-11-15T14:12:12" }'

curl -XPOST 'http://localhost:9200/_aliases' -d '
{
    "actions" : [
        { "add" : { "index" : "pb_data_phrase_0000", "alias" : "pb_data", "routing": "1" } },
        { "add" : { "index" : "pb_data_title_0000", "alias" : "pb_data", "routing": "1" } },
        { "add" : { "index" : "pb_data_synopsis_0000", "alias" : "pb_data", "routing": "1" } },
        { "add" : { "index" : "pb_data_url_0000", "alias" : "pb_data", "routing": "1" } },
        { "add" : { "index" : "pb_data_body_0000", "alias" : "pb_data", "routing": "1" } },

        { "add" : { "index" : "pb_data_phrase_0000", "alias" : "pb_phrase", "routing": "1" } },
        { "add" : { "index" : "pb_data_title_0000", "alias" : "pb_title", "routing": "1" } },
        { "add" : { "index" : "pb_data_synopsis_0000", "alias" : "pb_synopsis", "routing": "1" } },
        { "add" : { "index" : "pb_data_url_0000", "alias" : "pb_url_text", "routing": "1" } },
        { "add" : { "index" : "pb_data_body_0000", "alias" : "pb_body", "routing": "1" } },

        { "add" : { "index" : "pb_url_0000", "alias" : "pb_url", "routing": "1" } }

     ]
}'
curl -XDELETE 'http://localhost:9200/pb_data_title_0000/item/_query?q=v:10' -d '{
        "range": {
          "v": {
            "from": 10,
            "to": 10
          }
        }
}'
curl -s -XPOST localhost:9200/_bulk --data-binary '{"index":{"_index":"pb_title","_type":"item","_id":"MHTJvY36TdG4n6J9sSDCnQ_0fcJ44Ug","op_type":"update", "_timestamp": "2000-05-16T00:40:30.999Z" }}
{"script":"if((v=ctx._source).last_seen<ls){v.last_seen=ls;}else{ctx.op=\"none\"}","params":{"ls":"2012-05-16T00:40:39.999Z"}, "upsert":{"text":"FounderDating NYC - May 17th - Eventbrite","ctx":["www.eventbrite.com","eventbrite","event brite"],"boost":1.59,"last_seen":"2012-05-16T00:40:39.999Z","urlh":"MHTJvY36TdG4n6J9sSDCnQ"}}
'

curl -s -XPOST localhost:9200/_bulk --data-binary '{"index":{"_index":"pb_title","_type":"item","_id":"e-27vgJNRH2OkCg5KmjLZQ_Y44yFLw","op_type":"update"}}
{"script":"if((v=ctx._source).last_seen<ls){v.last_seen=ls;}else{ctx.op=\"none\"}","params":{"ls":"2011-03-09T17:47:28.523Z"},"upsert":{"text":"МЕТРО България: Специализирани каталози","ctx":["www.metro.bg","metro bg"],"boost":0.81,"last_seen":"2011-03-09T17:47:28.523Z","urlh":"e-27vgJNRH2OkCg5KmjLZQ"}}
'


curl -XDELETE 'http://localhost:9200/pb_word_segment/'

curl -XPUT localhost:9200/pb_word_segment -d '{
    "settings" : {
        "number_of_shards" : 1,
        "number_of_replicas" : 1
    },
    "mappings" : {
        "word" : {
                "dynamic" : false,
            "properties" : {
                "segment" : {
                    "type" : "string", 
                    "position_offset_gap" : 100
                }               
            },
            "_id" : { "path": "value" }
        }
    }
}'

curl -s -XPOST localhost:9200/_bulk --data-binary '{ "index" : { "_index" : "pb_word_segment", "_type" : "word", "_id" : "youtube", "op_type": "create"} }
{ "value" : "youtube", "segment" : [ "you", "tube" ] }
'
