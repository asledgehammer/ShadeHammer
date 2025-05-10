--- @class ModelOrientation
--- @field position Vector3f
--- @field rotation Vector3f
--- @field rotationPivot Vector3f
--- @field scale Vector3f
--- @field outlineScale Vector3f
--- @field zoom number

--- @type table<string, ModelOrientation>
return {

    default = {
        position = Vector3f.new(0.0, 0.0, 0.0),
        rotation = Vector3f.new(0.0, 0.0, 0.0),
        rotationPivot = Vector3f.new(0.0, 0.0, 0.0),
        scale = Vector3f.new(1.0, 1.0, 1.0),
        outlineScale = Vector3f.new(1.05, 1.05, 1.05),
        zoom = 10
    },

    BaseballBat = {
        position = Vector3f.new(0.0, -0.25, 0.0),
        rotation = Vector3f.new(0.0, 0.0, 45.0),
        scale = Vector3f.new(1.0, 1.0, 1.0),
        rotationPivot = Vector3f.new(0.0, 0.2, 0.0),
        outlineScale = Vector3f.new(1.5, 1.025, 1.5),
        zoom = 16
    },

    FireAxe = {
        position = Vector3f.new(0.0, -0.25, 0.0),
        rotation = Vector3f.new(0.0, 0.0, 22.5),
        scale = Vector3f.new(1.0, 1.0, 1.0),
        rotationPivot = Vector3f.new(0.0, 0.25, 0.0),
        outlineScale = Vector3f.new(1.15, 1.05, 1.15),
        zoom = 16
    },

};
