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
    for record in event['Records']:
        if record['eventName'] == "INSERT":
            insert_document(record)
        elif record['eventName'] == "REMOVE":
            remove_document(record)
        elif record['eventName'] == "MODIFY":
            modify_document(record)


def modify_document(record):
    table = get_table(record)
    doc_id = get_doc_id(record)
    doc = to_document(record)
    print("Attempting to modify document, Index=", table, ", DocumentID=", doc_id, ", DocumentBody=", doc)
    es.index(
        index=table,
        body=doc,
        id=doc_id,
        doc_type=table,
        refresh=True
    )
    print("Successfully modified document, Index=", table, ", DocumentID=", doc_id)


def remove_document(record):
    table = get_table(record)
    doc_id = get_doc_id(record)
    print("Attempting to remove document, Index=", table, ", DocumentID=", doc_id)
    es.delete(
        index=table,
        id=doc_id,
        doc_type=table,
        refresh=True,
        ignore=[404]
    )
    print("Successfully removed document, Index=", table, ", DocumentID=", doc_id)


def insert_document(record):
    table = get_table(record)
    # Create index if missing
    if not es.indices.exists(table):
        es.indices.create(table, body='{"settings": { "index.mapping.coerce": true } }')
        print("Created index that did not previously exist, Index=" + table)

    doc_id = get_doc_id(record)
    doc = to_document(record)
    print("Attempting to insert document, Index=", table, ", DocumentID=", doc_id, ", DocumentBody=", doc)
    es.index(
        index=table,
        body=doc,
        id=doc_id,
        doc_type=table,
        refresh=True
    )
    print("Successfully inserted document, Index=", table, ", DocumentID=", doc_id)


def get_table(record):
    p = re.compile('arn:aws:dynamodb:.*?:.*?:table/([0-9a-zA-Z_-]+)/.+')
    m = p.match(record['eventSourceARN'])
    if m is None:
        raise Exception("Table not found in SourceARN")
    return m.group(1).lower()


# converts a record and in its DDB JSON format to regular JSON
def to_document(record):
    doc = {}
    for k, v in record['dynamodb']['NewImage'].items():
        if "S" in v.keys() or "BOOL" in v.keys():
            doc[k] = v.get('S', v.get('BOOL', False))
        elif 'NULL' in v:
            doc[k] = None
    return json.dumps(doc)


def get_doc_id(record):
    doc_id = {}
    for k, v in record['dynamodb']['Keys'].items():
        if "S" in v.keys() or "BOOL" in v.keys():
            doc_id[k] = v.get('S', v.get('BOOL', False))
        elif 'NULL' in v:
            doc_id[k] = None
    return json.dumps(doc_id)
