local json = require("field.perceptron.json")


---@class perceptron
---@field private _weight_layers number[][][]
---@field private _layer_structure_data integer[]
---@field private _activation_f fun(input_value: number): number
---@field private _activation_f_derivative fun(input_value: number): number
local perceptron = {}
perceptron.__index = perceptron


---@public
---@param structure_data integer[]
---@param activation_f fun(input_value: number): number
---@param activation_f_derivative fun(input_value: number): number
---@return perceptron
---@nodiscard
function perceptron.new(structure_data,
                        activation_f,
                        activation_f_derivative)

    assert(type(structure_data) == "table")
    assert(#structure_data >= 2)
    for _, value in ipairs(structure_data) do
        assert(value > 0)
    end

    assert(type(activation_f) == "function")
    assert(type(activation_f(0.0) == "number"))

    assert(type(activation_f_derivative) == "function")
    assert(type(activation_f_derivative(0.0) == "number"))

    ---@type number[][][]
    local weight_layers = {}

    for i = 1, #structure_data - 1 do

        ---@type integer
        local neuron_input_slots = structure_data[i]

        ---@type integer
        local neurons_count = structure_data[i + 1]

        ---@type number
        local xavier_coef = 1 / math.sqrt(neuron_input_slots)

        ---@type integer[][]
        local weight_layer = {}

        for _ = 1, neurons_count do

            ---@type integer[]
            local neuron_vector = {}
            for k = 1, neuron_input_slots + 1 do -- +1 for bias

                ---@type number
                local normal_range = math.random() * 2 - 1
                neuron_vector[k] = normal_range * xavier_coef -- xavier initialization
            end

            table.insert(weight_layer, neuron_vector)
        end

        table.insert(weight_layers, weight_layer)
    end

    ---@type perceptron
    local self = setmetatable({
        _layer_structure_data = structure_data,
        _weight_layers = weight_layers,
        _activation_f = activation_f,
        _activation_f_derivative = activation_f_derivative
    }, perceptron)

    return self
end


---@public
---@param other perceptron
---@return perceptron
---@nodiscard
function perceptron.new_deep_copy(other)

    ---@type number[][][]
    local weight_layers_copy = {}
    for _, layer in ipairs(other._weight_layers) do
        ---@type number[][]
        local weight_layer_copy = {}
        for _, neuron in ipairs(layer) do
            ---@type number[]
            local neuron_copy = {}
            for _, value in ipairs(neuron) do
                table.insert(neuron_copy, value)
            end
            table.insert(weight_layer_copy, neuron_copy)
        end
        table.insert(weight_layers_copy, weight_layer_copy)
    end

    ---@type integer[]
    local layer_structure_data_copy = {}
    for _, value in ipairs(other._layer_structure_data) do
        table.insert(layer_structure_data_copy, value)
    end

    ---@type perceptron
    local self = setmetatable({
        _layer_structure_data = layer_structure_data_copy,
        _weight_layers = weight_layers_copy,
        _activation_f = other._activation_f,
        _activation_f_derivative = other._activation_f_derivative
    }, perceptron)

    return self
end



---@private
---@param layer_number integer
---@return integer -- total layer weight count
---@nodiscard
function perceptron:get_layer_weight_count(layer_number)
    assert(layer_number > 0 and layer_number < #self._layer_structure_data)

    return self._layer_structure_data[layer_number] 
        * self._layer_structure_data[layer_number]
end


---@private
---@return integer -- total perceptron weight count
---@nodiscard
function perceptron:get_total_weight_count()

    ---@type integer
    local total_weight_count = 0
    for i = 1, (#self._layer_structure_data) - 1 do
        total_weight_count = total_weight_count +
            self:get_layer_weight_count(i)

    end

    return total_weight_count
end


---@public
function perceptron:mutate()

    ---@type integer
    local mutation_index = math.random(self:get_total_weight_count())

    -- locate layer
    ---@type integer
    local mutated_layer_index = nil

    ---@type integer
    local total_layer_values = 0

    for i = 1, (#self._layer_structure_data) - 1 do
        ---@type integer
        local layer_size = self:get_layer_weight_count(i)
        if mutation_index <= total_layer_values + layer_size then
            mutated_layer_index = i
            break
        else
            total_layer_values = total_layer_values + layer_size
        end
    end
    assert(mutated_layer_index)

    mutation_index = mutation_index - total_layer_values

    ---@type integer
    local neuron_size = #(self._weight_layers[mutated_layer_index][1])
    ---@type integer
    local mutated_neuron_index = math.ceil(mutated_layer_index / neuron_size)

    ---@type number[]
    local mutated_neuron = self._weight_layers[mutated_layer_index][mutated_neuron_index]
    assert(mutated_neuron, "mli = "..mutated_layer_index.." mni = "..mutated_neuron_index)

    ---@type integer
    local mutated_weight_index = mutated_layer_index % neuron_size

    local xavier_coef = 1 / math.sqrt(neuron_size)
    mutated_neuron[mutated_weight_index] = (math.random() * 2 - 1) * xavier_coef
end


---@public
---@param input number[]
---@return number[]
---@nodiscard
function perceptron:run(input)

    assert(type(input) == "table",
           "perceptron input is wrong type: " .. type(input))

    assert(#input == #(self._weight_layers[1][1]) - 1, -- -1 for bias
           "perceptron input == " .. #input ..
           ", first layer input == " .. #(self._weight_layers[1][1]) - 1)

    for index, value in ipairs(input) do
        assert(type(value) == "number",
               "type of input[" .. index .. "] = " .. type(value))
    end

    ---@type number[]
    local line = {}
    for _, value in ipairs(input) do
        line[#line + 1] = value
    end

    ---@type number[]
    for _, weight_layer in ipairs(self._weight_layers) do

        ---@type number[]
        local new_line = {}
        for _, neuron in ipairs(weight_layer) do

            ---@type number
            local sum = 0

            for i = 1, #neuron - 1 do
                sum = sum + neuron[i] * line[i]
            end
            sum = sum + neuron[#neuron] -- add bias

            table.insert(new_line, sum)
        end
        for i = 1, #new_line do
            new_line[i] = self._activation_f(new_line[i])
        end
        line = new_line
    end

    return line
end


---@private
---@param input number[]
---@return number[][]
---@nodiscard
function perceptron:run_teach(input)

    assert(type(input) == "table")
    for _, value in ipairs(input) do
        assert(type(value) == "number", type(value))
    end
    assert(#input == #(self._weight_layers[1][1]) - 1) -- -1 for bias

    ---@type number[][]
    local layers_output = {}

    ---@type number[]
    local line = {}
    for _, value in ipairs(input) do
        table.insert(line, value)
    end

    ---@type number[]
    for _, weight_layer in ipairs(self._weight_layers) do

        ---@type number[]
        local new_line = {}
        for _, neuron in ipairs(weight_layer) do

            ---@type number
            local sum = 0

            for i, value in ipairs(neuron) do
                sum = sum + value * (line[i] or 1) -- add bias
            end

            table.insert(new_line, sum)
        end
        for i = 1, #new_line do
            new_line[i] = self._activation_f(new_line[i])
        end
        line = new_line
        table.insert(layers_output, new_line)
    end

    return layers_output
end


---@package
---@param weight_layer number[][]
---@param previous_layer_output number[]
---@param current_layer_output number[]
---@param error_array number[]
---@param activation_f_derivative fun(input: number): number
---@param training_step number
---@return nil
local function update_layer(weight_layer,
                            previous_layer_output,
                            current_layer_output,
                            error_array,
                            activation_f_derivative,
                            training_step)

    ---@type integer
    local neuron_count = #weight_layer

    ---@type number
    local neuron_input = #weight_layer[1]

    assert(neuron_count == #error_array - 1,
           neuron_count .. " " .. #error_array - 1) -- -1 for bias
    assert(neuron_count == #current_layer_output,
           neuron_count .. " " .. #current_layer_output)
    assert(neuron_input == #previous_layer_output + 1,
           neuron_input .. " " .. #previous_layer_output + 1) -- +1 for bias

    assert(type(activation_f_derivative(0)) == "number")

    for i = 1, neuron_count do
        for j = 1, neuron_input do
            ---@type number
            local change = training_step * error_array[i] *
                               activation_f_derivative(current_layer_output[i]) *
                               (previous_layer_output[j] or 1)

            weight_layer[i][j] = weight_layer[i][j] - change
        end
    end

end


---@private
---@param output_errors number[]
---@return  number[][]
---@nodiscard
function perceptron:backpropagate_error(output_errors)

    table.insert(output_errors, 1) -- dummy bias
    ---@type number[][]
    local layer_errors_array = {[#self._weight_layers] = output_errors}

    for layer_n = #self._weight_layers, 1, -1 do
        -- print("layer_n = ", layer_n)
        ---@type number[][]
        local current_weight_layer = self._weight_layers[layer_n]

        ---@type number[]
        local current_error_array = layer_errors_array[layer_n]

        assert(#current_error_array == #current_weight_layer + 1,
               #current_error_array .. " != " .. #current_weight_layer + 1)

        ---@type number[]
        local new_error_array = {}
        for i , neuron in ipairs(current_weight_layer) do
            for j , value in ipairs(neuron) do

                ---@type number
                local change = (value * current_error_array[i])

                if new_error_array[j] then
                    new_error_array[j] = new_error_array[j] + change
                else
                    new_error_array[j] = change
                end
            end
        end

        layer_errors_array[layer_n - 1] = new_error_array
    end

    return layer_errors_array
end


---@public
---@param input number[]
---@param expected_result number[]
---@param education_step number
---@return nil
function perceptron:teach(input, expected_result, education_step)

    assert(type(expected_result) == "table")
    for _, value in ipairs(expected_result) do
        assert(type(value) == "number")
    end

    assert(#expected_result == #(self._weight_layers[#self._weight_layers]))

    assert(type(education_step) == "number")
    assert(education_step > 0 and education_step < 1)

    ---@type number[][]
    local layer_outputs = self:run_teach(input)

    -- generate layer errors

    ---@type number[]
    local last_layer_error_array = {}
    local last_layer_output = layer_outputs[#layer_outputs]
    for i = 1, #last_layer_output do
        table.insert(last_layer_error_array,
                     last_layer_output[i] - expected_result[i])
    end

    assert(#last_layer_error_array == #last_layer_output)
    assert(#last_layer_error_array > 0)
    ---@type number[][]
    local layer_errors = self:backpropagate_error(last_layer_error_array)
    assert(#layer_errors == #self._weight_layers,
           "#le = " .. #layer_errors .. "#wl = " .. #self._weight_layers)

    for layer_n = #self._weight_layers, 2, -1 do

        ---@type number[]
        local previous_layer_output = layer_outputs[layer_n - 1]

        ---@type number[][]
        local weight_layer = self._weight_layers[layer_n]

        ---@type number[]
        local current_layer_output = layer_outputs[layer_n]

        ---@type number[]
        local error_array = layer_errors[layer_n]

        update_layer(weight_layer, previous_layer_output, current_layer_output,
                     error_array, self._activation_f_derivative, education_step)
    end

end



--[[
---@public
---@param file_path string
---@param activation_f fun(input_value: number): number
---@param activation_f_derivative fun(input_value: number): number
---@return perceptron
---@nodiscard
function perceptron.new_from_file(file_path, activation_f, activation_f_derivative)

    assert(type(activation_f) == "function")
    assert(type(activation_f(0.0) == "number"))

    assert(type(activation_f_derivative) == "function")
    assert(type(activation_f_derivative(0.0) == "number"))

    assert(file_path)

    ---@type file*?
    local file = io.open(file_path, "r")
    assert(file)

    ---@type string
    local str = file:read("*l")

    file:close()

    ---@type number[][][]
    local weight_layers = json.decode(str)

    assert(type(weight_layers) == "table")
    assert(type(weight_layers[1]) == "table")
    assert(type(weight_layers[1][1]) == "table")
    assert(type(weight_layers[1][1][1]) == "number")

    ---@type integer[]
    local structure_data = {}
    for _, value in ipairs(weight_layers) do
        table.insert(structure_data, #value)
    end

    ---@type integer
    local output_size = #(weight_layers[#weight_layers][1]) - 1
    table.insert(structure_data, output_size) -- -1 for bias

    ---@type perceptron
    local self = setmetatable({
        _layer_structure_data = structure_data,
        _weight_layers = weight_layers,
        _activation_f = activation_f,
        _activation_f_derivative = activation_f_derivative
    }, perceptron)

    return self
end
---@public
---@param output_file string
---@return bool
function perceptron:save_weights_to_file(output_file)

    assert(type(output_file) == "string")

    ---@type file*?
    local file = io.open(output_file, "w")
    assert(file)

    file:write(json.encode(self._weight_layers))

    return true
end
]]--


return perceptron
