def __get_scalar_value(ddb_value: dict):
    """
    returns the scalar value of a dynamodb JSON tuple
    for example: { "S": "Foo" } becomes "Foo" and
    { "L": [ ... ] } becomes just "[]"
    :param ddb_value:  the tuple
    :return: a scalar value
    """
    if "L" in ddb_value:
        return []
    elif "M" in ddb_value:
        return {}
    elif "S" in ddb_value:
        return ddb_value["S"]
    elif "N" in ddb_value:
        return float(ddb_value["N"])
    elif "BOOL" in ddb_value:
        return ddb_value["BOOL"]
    elif "B" in ddb_value:
        return ddb_value["B"]
    elif "SS" in ddb_value:
        return ddb_value["SS"]
    elif "BS" in ddb_value:
        return ddb_value["BS"]
    elif "NS" in ddb_value:
        return [float(i) for i in ddb_value["NS"]]
    elif "NULL" in ddb_value:
        return None
    raise Exception("Unrecognized type")


def __attach(parent: list or dict, ddb_node: dict or tuple):
    """
    Attach a scalar value to a parent, returns the attached scalar value
    :return: the scalar value extracted from ddb_tuple
    """
    if isinstance(parent, list):
        scalar_value = __get_scalar_value(ddb_node)
        parent.append(scalar_value)
        return scalar_value
    elif isinstance(parent, dict):
        prop, ddb_node = ddb_node
        scalar_value = __get_scalar_value(ddb_node)
        parent[prop] = scalar_value
        return scalar_value


def __children_of_ddb_dict(ddb_dict: dict):
    if "M" in ddb_dict:
        items_ = [i for i in ddb_dict["M"].items()]
        items_.reverse()
        return items_
    elif "L" in ddb_dict:
        items_ = ddb_dict["L"]
        items_.reverse()
        return items_
    else:
        return []


def __children_of(ddb_node: tuple or dict):
    """
    Return the children of the DynamoDB tuple ddb_tuple
    the value of ddb_tuple could already be a list or a dict
    for map like child values we transform the dict into a list of tuples
    """
    if isinstance(ddb_node, dict):
        # parent is list like - take as is
        return __children_of_ddb_dict(ddb_node)
    elif isinstance(ddb_node, tuple):
        # parent is dict like - go one level deeper
        _, ddb_node = ddb_node
        return __children_of_ddb_dict(ddb_node)


def dump(ddb_dict):
    """
    Returns the Python dictionary version of any DynamoDB document annotated with DynamoDB type information
    :param ddb_dict: the input DynamoDB object (as a dictionary) 
    :return: the Python dict stripped of type information, ready to be turned into a JSON string if needed
    """
    # use two stacks to track what must be processed and what parents it must be attached it
    processing_stack: list[tuple or dict] = [t for t in ddb_dict.items()]
    # call reverse to preserve input order
    processing_stack.reverse()

    # data structure to keep track the list of parents to pop, the last element
    # on this list is the parent to attach new values to
    parents: list[tuple] = []
    root = {}
    parents.append((root, None))

    # begin DFS traversal on every node in the input, stopping condition is when we run out of nodes to process
    while len(processing_stack) != 0:
        # grab the most recent parent
        parent, last_node = parents[len(parents) - 1]
        current_node = processing_stack.pop()

        child_value = __attach(parent, current_node)

        if last_node == current_node:
            parents.pop()

        # children will be empty if the current_node is a scalar or simple set
        children = __children_of(current_node)
        if len(children) != 0:
            for child in children:
                processing_stack.append(child)
            # children[0] = the last_node, we store it with the parent so we know when the pop the parent
            parents.append((child_value, children[0]))

    return root
