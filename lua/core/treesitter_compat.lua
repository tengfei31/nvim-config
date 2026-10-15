local M = {}

function M.setup()
    if vim.fn.has("nvim-0.12") == 0 then
        return
    end

    -- Legacy nvim-treesitter uses all=false (one node per capture).
    -- Neovim 0.12 removed that option and always passes node lists.
    -- Adapt only handlers registered by this module, then restore the API.
    local query = vim.treesitter.query
    local original = {
        add_predicate = query.add_predicate,
        add_directive = query.add_directive,
    }
    for name, register in pairs(original) do
        query[name] = function(key, handler, opts)
            if type(opts) == "table" and opts.all == false then
                local legacy_handler = handler
                handler = function(match, ...)
                    local nodes = {}
                    for id, captures in pairs(match) do
                        nodes[id] = type(captures) == "table" and captures[#captures] or captures
                    end
                    return legacy_handler(nodes, ...)
                end
            end
            return register(key, handler, opts)
        end
    end

    local module = "nvim-treesitter.query_predicates"
    package.loaded[module] = nil
    local ok, err = pcall(require, module)
    for name, register in pairs(original) do
        query[name] = register
    end
    if not ok then
        error(err)
    end
end

return M
