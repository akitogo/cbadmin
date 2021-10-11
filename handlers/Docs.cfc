component
{
    property name="ormService"       inject = "baseORMService@cborm";
    property name="JSONPrettyPrint"  inject = "JSONPrettyPrint@JSONPrettyPrint";

    function generate(event, rc, prc)
    {
        // Run script only in development mode.
        if (getSetting("environment") neq "development") {
            abort;
        }

        var fileDir = '';
        var apidocsRootPath = ExpandPath(event.getModuleRoot() & '/resources/apidocs/');

        var modelsToGenerate = [
            { "entityName" = "cbPermission", "dirName" = "Permission" }
            , { "entityName" = "cbPermissionGroup", "dirName" = "PermissionGroup" }
            , { "entityName" = "cbRole", "dirName" = "Role" }
        ];

        for (model in modelsToGenerate) {
            emptyModel = ormService.new(entityName = model.entityName);
            fileDir = apidocsRootPath & model.dirName;
            this.saveObjectJsonToFiles(emptyModel, fileDir);
        }

        abort;
    }

        /**
     * This function will generate the JSON for the passed object and create
     * the getObject.json and postObject.json files.
     */
    private function saveObjectJsonToFiles(object, path)
    {
        var objectProperties = this._getObjectProperties(object);

        // Generate and save the getObject.json file
        FileWrite(file = path & '\getObject.json', data = JSONPrettyPrint.formatJSON(_getObjectJson(objectProperties.getFields)), charset = "UTF-8");

        // Generate and save the postObject.json file
        FileWrite(file = path & '\postObject.json', data = JSONPrettyPrint.formatJSON(_getObjectJson(objectProperties.postFields)), charset = "UTF-8");
    }

    /**
     * This function prepares the full JSON for a given object.
     */
    private function _getObjectJson(objectProperties)
    {
        var objectData = {
            "type" = "object",
            "properties" = objectProperties
        };
        var json = serializeJSON(objectData);
        return json;
    }

    /**
     * This function returns two sets of property definitions for OpenAPI: one
     * for GET requests and the other for POST/PUT/PATCH requests.
     */
    private function _getObjectProperties(object)
    {
        // additionally for POST/PUT/PATCH calls, ignore these fields:
        // when setter is set and is false
        // when update is set and is false
        
        //dump(structKeyArray(object.getMemento()));

        var getFields = {};
        var postFields = {};
        var propDefinitions = object.$getDeepProperties();

        for (prop in propDefinitions) {
            var propDescription = var propType = var propExample = '';

            // Skip duplicates, injections
            if (structKeyExists(getFields, prop.name) || structKeyExists(prop, 'inject')
            ) {
                continue;
            }

            // Check the 'openapidocs' attribute of the property to pull data.
            propDescription = this._getOpenapidocsField(prop, 'description');
            propExample = this._getOpenapidocsField(prop, 'example');

            // Fallback for the 'description' field
            if (!Len(propDescription)) {
                propDescription = prop.name;
            }

            var openapidocsFallback = this._getOpenapidocsFallback(prop);

            // Fallback for type
            if (!Len(propType)) {
                propType = openapidocsFallback.type;
            }

            // Prepare the struct for GET requests.
            var propExampleGetRequest = propExample;
            if (!Len(propExampleGetRequest)) {
                if (openapidocsFallback.type == 'array') {
                    propExampleGetRequest = openapidocsFallback.get_example;
                } else {
                    propExampleGetRequest = openapidocsFallback.example;
                }
            }
            newFieldGetRequest = {
                "description" = propDescription,
                "type" = propType,
                "example" = propExampleGetRequest
            };
            if (propType == 'array') {
                structInsert(newFieldGetRequest, 'items', {
                    'type' = 'object'
                });
            }
            structInsert(getFields, prop.name, newFieldGetRequest);

            // If this field is not explicitly excluded from POST requests, add it also to the postFields struct.
            if (!BooleanFormat(this._getOpenapidocsField(prop, 'exclude_post'))) {
                var propExamplePostRequest = propExample;
                if (!Len(propExamplePostRequest)) {
                    if (openapidocsFallback.type == 'array') {
                        propExamplePostRequest = openapidocsFallback.post_example;
                    } else {
                        propExamplePostRequest = openapidocsFallback.example;
                    }
                }
                newFieldPostRequest = {
                    "description" = propDescription,
                    "type" = propType,
                    "example" = propExamplePostRequest
                };
                if (propType == 'array') {
                    structInsert(newFieldPostRequest, 'items', {
                        'type' = 'integer'
                    });
                }
                structInsert(postFields, prop.name, newFieldPostRequest);
            }
        }

        return {
            'getFields' = getFields,
            'postFields' = postFields
        };
    }

    /**
     * If the openapidocs attribute is set for a given property,
     * retrieve the requested field (ex. example field, description field...).
     */
    private function _getOpenapidocsField(property, field)
    {
        if (structKeyExists(property, 'openapidocs')) {
            openapidocs = deserializeJSON(property.openapidocs);
            if (structKeyExists(openapidocs, field)) {
                return openapidocs[field];
            }
        }
        return '';
    }

    /**
     * In case the openapidocs attribute of the property is missing, try to generate
     * the 'type' and 'example' fields based on the property definition.
     */
    private function _getOpenapidocsFallback(property)
    {
        var loremIpsumExample = 'Lorem ipsum dolor sit amet...';

        if (structKeyExists(property, 'type')) {
            switch (property.type) {
                case 'date':
                    return {
                        'type' = 'string',
                        'example' = dateTimeFormat(now(), 'yyyy-mm-dd HH:nn:ss')
                    };
            }
        }

        if (structKeyExists(property, 'ormtype')) {
            switch (property.ormtype) {
                case 'boolean':
                    return {
                        'type' = 'boolean',
                        'example' = true
                    };
                case 'string':
                    return {
                        'type' = 'string',
                        'example' = loremIpsumExample
                    };
            }
        }

        if (structKeyExists(property, 'type') && property.type == 'array' && structKeyExists(property, 'fieldtype')) {
            var example_object_type = 'object';
            if (structKeyExists(property, 'singularname')) {
                example_object_type = property.singularname & ' object';
            }
            return {
                'type' = 'array',
                'get_example' = [ '{ ' & example_object_type & ' }', '{ ' & example_object_type & ' }', '{ ' & example_object_type & ' }'],
                'post_example' = [ 123, 456, 789 ]
            };
        }

        return {
            'type' = 'string',
            'example' = loremIpsumExample
        };
    }
}