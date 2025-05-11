---@module "field.bot_actions"
local bot_actions = require("field.bot_actions")

---@module "field.bot_rotation"
local bot_rotation = require("field.bot_rotation")

---@type integer
local CONST_INITIAL_MIN_ENERGY = 5

---@type integer
local CONST_INITIAL_MAX_ENERGY = 7

---@type integer
local CONST_MULTIPLY_COST = 11

---@type integer
local CONST_BRAIN_MUTATION_SPAWN_PROB = 1

---@type integer
local CONST_BRAIN_MUTATION_ACTION_PROB = 10

---@type integer
local CONST_GENE_MUTATION_SPAWN_PROB = 1000

---@type integer
local CONST_MAX_BOT_AGE = 500

---@type integer
local CONST_MAX_GENE_VALUE = 94

---@type integer
local CONST_MIN_GENE_VALUE = 33

---@type integer[]
local CONST_BRAIN_STRUCTURE = {6, 3 + bot_actions.ACTION_SIZE}

local config = {
    CONST_INITIAL_MIN_ENERGY = CONST_INITIAL_MIN_ENERGY,
    CONST_INITIAL_MAX_ENERGY = CONST_INITIAL_MAX_ENERGY,
    CONST_MULTIPLY_COST = CONST_MULTIPLY_COST,
    CONST_MAX_BOT_AGE = CONST_MAX_BOT_AGE,
    CONST_BRAIN_STRUCTURE = CONST_BRAIN_STRUCTURE,
    CONST_BRAIN_MUTATION_SPAWN_PROB = CONST_BRAIN_MUTATION_SPAWN_PROB,
    CONST_BRAIN_MUTATION_ACTION_PROB = CONST_BRAIN_MUTATION_ACTION_PROB,
    CONST_GENE_MUTATION_SPAWN_PROB = CONST_GENE_MUTATION_SPAWN_PROB,
    CONST_MIN_GENE_VALUE = CONST_MIN_GENE_VALUE,
    CONST_MAX_GENE_VALUE = CONST_MAX_GENE_VALUE,
}

return config
