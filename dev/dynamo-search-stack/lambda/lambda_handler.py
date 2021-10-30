import json
import os
import re

from elasticsearch import Elasticsearch

es = Elasticsearch(
    hosts=[os.environ["ES_ENDPOINT"]],
    use_ssl=True,
    verify_certs=True,
    port=443
)

reserved_fields = ["uid", "_id", "_type", "_source", "_all", "_parent", "_fieldnames", "_routing", "_index", "_size",
                   "_timestamp", "_ttl"]


def lambda_handler(event, context):
    print(event)
    # dynamodb = boto3.resource('dynamodb')

    # Loop over the DynamoDB Stream records
    for record in event['Records']:

        if record['eventName'] == "INSERT":
            insert_document(event, es, record)
        elif record['eventName'] == "REMOVE":
            remove_document(event, es, record)
        elif record['eventName'] == "MODIFY":
            modify_document(event, es, record)


# Process MODIFY events
def modify_document(event, es, record):
    table = getTable(record)
    print("Dynamo Table Update: " + table)

    docId = docid(event, event)
    print("KEY")
    print(docId)

    # Unmarshal the DynamoDB JSON to a normal JSON
    doc = json.dumps(document(event))

    print("Updated document:")
    print(doc)

    # We reindex the whole document as ES accepts partial docs
    es.index(index=table,
             body=doc,
             id=docId,
             doc_type=table,
             refresh=True)

    print("Successfully modified - Index: ", table, " - Document ID: ", docId)


def remove_document(event, es, record):
    table = getTable(record)

    print("Dynamo Table Removed: " + table)

    docId = docid(event, event)
    print("Deleting document ID: ", docId)

    es.delete(
        index=table,
        id=docId,
        doc_type=table,
        refresh=True,
        ignore=[404]
    )

    print("Successfully removed - Index: ", table, " - Document ID: ", docId)


# Process INSERT events
def insert_document(event, es, record):
    table = getTable(record)
    print("Dynamo Table Inserted: " + table)

    # Create index if missing
    if not es.indices.exists(table):
        print("Create missing index: " + table)

        es.indices.create(table,
                          body='{"settings": { "index.mapping.coerce": true } }')

        print("Index created: " + table)

    # Unmarshal the DynamoDB JSON to a normal JSON
    doc = json.dumps(document(event))

    print("New document to Index:")
    print(doc)

    newId = docid(event, record)

    es.index(index=table,
             body=doc,
             id=newId,
             doc_type=table,
             refresh=True)

    print("Successfully inserted - Index: ", table + " - Document ID: ", newId)


def getTable(record):
    p = re.compile('arn:aws:dynamodb:.*?:.*?:table/([0-9a-zA-Z_-]+)/.+')
    m = p.match(record['eventSourceARN'])
    if m is None:
        raise Exception("Table not found in SourceARN")
    return m.group(1).lower()


def document(event):
    result = []
    for r in event['Records']:
        tmp = {}
        for k, v in r['dynamodb']['NewImage'].items():
            if "S" in v.keys() or "BOOL" in v.keys():
                tmp[k] = v.get('S', v.get('BOOL', False))
            elif 'NULL' in v:
                tmp[k] = None
        result.append(tmp)
        for i in result:
            return i


def docid(event, record):
    result = []
    for r in event['Records']:
        tmp = {}
        for k, v in r['dynamodb']['Keys'].items():
            if "S" in v.keys() or "BOOL" in v.keys():
                tmp[k] = v.get('S', v.get('BOOL', False))
            elif 'NULL' in v:
                tmp[k] = None
        result.append(tmp)
    for newId in result:
        return newId
