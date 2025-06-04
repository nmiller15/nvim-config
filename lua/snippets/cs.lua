local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local plenary_path = require 'plenary.path'

-- Class name from filename
local function filename_to_classname()
  return vim.fn.expand '%:t:r'
end

-- Recursively find the project root
local function find_project_root()
  local path = plenary_path:new(vim.fn.expand '%:p'):parent()

  while path do
    local has_git = path:joinpath('.git'):exists()
    local has_sln = vim.fn.glob(path.filename .. '/*.sln') ~= ''
    local has_csproj = vim.fn.glob(path.filename .. '/*.csproj') ~= ''

    if has_git or has_sln or has_csproj then
      return path
    end

    local parent = path:parent()
    if parent.filename == path.filename then
      break
    end
    path = parent
  end

  return nil
end

-- Namespace from folder structure relative to project root
local function derive_namespace()
  local file_path = plenary_path:new(vim.fn.expand '%:p')
  local project_root = find_project_root()
  if not project_root then
    return 'UnknownNamespace'
  end

  local rel_path = file_path:make_relative(project_root.filename)

  local namespace = rel_path
    :gsub('[/\\]?[^/\\]+%.cs$', '') -- remove filename
    :gsub('[/\\]', '.') -- convert to dot-separated
    :gsub('^%.+', '') -- remove leading dots

  return namespace ~= '' and namespace or 'RootNamespace'
end

-- Class Snippet
ls.add_snippets('cs', {
  s('cl_class', {
    t 'namespace ',
    f(derive_namespace, {}),
    t { '', '{' },
    t { '    public class ' },
    f(filename_to_classname, {}),
    t { '', '    {', '        ' },
    i(0),
    t { '', '    }', '}' },
  }),
})

-- Interface Snippet
ls.add_snippets('cs', {
  s('in_interface', {
    t 'namespace ',
    f(derive_namespace, {}),
    t { '', '{' },
    t { '    public interface ' },
    f(filename_to_classname, {}),
    t { '', '    {', '        ' },
    i(0),
    t { '', '    }', '}' },
  }),
})
