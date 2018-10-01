-- playpen for silly ideas
-- plz ignore
function hasTable(t)
  local mt={__index = function() return {} end}
  setmetatable(t,mt)
end

t={}

