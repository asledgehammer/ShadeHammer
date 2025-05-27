--- @param object any The Java object to reflect.
--- @param field table|string|number Either a `java.lang.reflect.Field`, a field-index, or a field-name.
---
--- @return any FieldValue Either the value of the field or `nil` if the field is unresolved.
local function getJavaFieldValue(object, field)
    local typeField = type(field);
    -- If a table, this might be a passed `java.lang.reflect.Field` object.
    if typeField == 'table' then
        return getClassFieldVal(object, field);
        -- If a number is provided, use this as the index to more directly access the value.
    elseif typeField == 'number' then
        local javaField = getClassField(object, field);
        if not javaField then return nil end
        return getClassFieldVal(object, javaField);
    else
        -- A field-name is provided.
        local offset = string.len(field);
        for i = 0, getNumClassFields(object) - 1 do
            local m = getClassField(object, i);
            if string.sub(tostring(m), -offset) == field then
                return getClassFieldVal(object, m);
            end
        end
        return nil;
    end
end

--- @param object any The Java object to reflect.
--- @param path string
---
--- @return any FieldValue Either the value of the field or `nil` if the field is unresolved.
local function getJavaFieldValueExact(object, path)
    for i = 0, getNumClassFields(object) - 1 do
        local m = getClassField(object, i);
        if string.find(tostring(m), path, 1, true) ~= nil then
            return getClassFieldVal(object, m);
        end
    end
    return nil;
end

--- @param object any
--- @param fields string[]
---
--- @return table<string, any>
local function getJavaFieldValues(object, fields)
    local values = {};
    for _, field in ipairs(fields) do
        local offset = string.len(field);
        for i = 0, getNumClassFields(object) - 1 do
            local fieldIndex = getClassField(object, i);
            if string.sub(tostring(fieldIndex), -offset) == field then
                values[field] = getClassFieldVal(object, fieldIndex);
            end
        end
    end
    return values;
end

--- @param object any
---
--- @return table<string, any>
local function getAllJavaFieldValues(object)
    local values = {};
    for i = 0, getNumClassFields(object) - 1 do
        local fieldIndex = getClassField(object, i);
        values[i] = tostring(fieldIndex) .. ' = ' .. tostring(getClassFieldVal(object, fieldIndex));
    end
    return values;
end

--- @param object any
---
--- @return table<string, any>
local function printJavaFields(object)
    local values = getAllJavaFieldValues(object);
    local s_values = '';
    for key, val in pairs(values) do
        if s_values == '' then
            s_values = '\t"' .. tostring(key) .. '" = ' .. tostring(val) .. '\n';
        else
            s_values = s_values .. '\t"' .. tostring(key) .. '" = ' .. tostring(val) .. '\n';
        end
    end
    print(
        'getJavaFields(object = ' .. tostring(object) .. ') = {\n' .. s_values .. '}\n'
    );
    return values;
end

--- @param object any
--- @param method string
---
--- @return Method | nil
local function getJavaMethod(object, method)
    for i = 0, getNumClassFunctions(object) - 1 do
        local m = getClassFunction(object, i);
        if string.match(tostring(m), '%.' .. method .. '%(') then
            return m;
        end
    end
    return nil;
end

--- @param object any
--- @param methods string[]
---
--- @return table<string, Method>
local function getJavaMethods(object, methods)
    local values = {};
    for _, method in ipairs(methods) do
        for i = 0, getNumClassFunctions(object) - 1 do
            local m = getClassFunction(object, i);
            if string.match(tostring(m), '%.' .. method .. '%(') then
                return m;
            end
        end
    end
    return values;
end

_G.getJavaFieldValueExact = getJavaFieldValueExact;
_G.getAllJavaFieldValues = getAllJavaFieldValues;
_G.getJavaFieldValue = getJavaFieldValue;
_G.getJavaFieldValues = getJavaFieldValues;
_G.printJavaFields = printJavaFields;
_G.getJavaMethod = getJavaMethod;
_G.getJavaMethods = getJavaMethods;

return {
    getJavaFieldValueExact = getJavaFieldValueExact,
    getAllJavaFieldValues = getAllJavaFieldValues,
    getJavaFieldValue = getJavaFieldValue,
    getJavaFieldValues = getJavaFieldValues,
    printJavaFields = printJavaFields,
    getJavaMethod = getJavaMethod,
    getJavaMethods = getJavaMethods,
};
