-- Pandoc filter to format a Pandoc Markdown document into a LaTeX one following the virtio
-- specification format.
-- To use:
--
-- pandoc --lua-filter virtio.lua --listings virtio-video.md -t latex
if FORMAT ~= 'latex' then
    return {}
end

-- Configurable values:
-- Prefix that will always be output in the section label.
SECTION_LABEL_PREFIX = "Device Types"



-- Array of section/subsection hierarchy so we can build the label for the current section.
SECTION_LABEL_LEVELS = {}

-- Format section headers the way they are expected to be. In particular, support the
-- "devicenormative" and "drivernormative" attributes to add the corresponding LaTeX code.
function Header(el)
    local class = ""

    local section = "unknown"
    if el.level == 1 then
        section = "section"
    elseif el.level == 2 then
        section = "subsection"
    elseif el.level == 3 then
        section = "subsubsection"
    elseif el.level == 4 then
        section = "paragraph"
    elseif el.level == 5 then
        section = "subparagraph"
    end

    local title = pandoc.utils.stringify(el.content)

    -- Update the labels hierarchy.
    if el.level > #SECTION_LABEL_LEVELS then
        -- Add empty sections if we jumped levels.
        while #SECTION_LABEL_LEVELS < el.level - 1 do
            table.insert(SECTION_LABEL_LEVELS, "")
        end
    else
        -- Remove sections if we are going to a lower level.
        while el.level <= #SECTION_LABEL_LEVELS do
            table.remove(SECTION_LABEL_LEVELS)
        end
    end

    if title:lower() == "device requirements" then
        class = "devicenormative"
        title = SECTION_LABEL_LEVELS[#SECTION_LABEL_LEVELS]
    elseif title:lower() == "driver requirements" then
        class = "drivernormative"
        title = SECTION_LABEL_LEVELS[#SECTION_LABEL_LEVELS]
    else
        class = ""
        -- Add the current title to the labels hierarchy.
        table.insert(SECTION_LABEL_LEVELS, title)
    end

    local label = SECTION_LABEL_PREFIX .. " / " .. table.concat(SECTION_LABEL_LEVELS, " / ");

    if class == "" then
        return pandoc.RawBlock('latex', string.format("\\%s{%s}\\label{sec:%s}", section, title, label))
    else
        return pandoc.RawBlock('latex', string.format("\\%s{\\%s}{%s}{%s}", class, section, title, label))
    end
end

function Code(el)
    -- Enable to only modify code with the "field" class, e.g. `some_code`{.field}
    --if el.classes[1] == "field" then
    --    return pandoc.RawInline('latex', string.format("\\field{%s}", el.text))
    --end
    return pandoc.RawInline('latex', string.format("\\field{%s}", el.text))
end

-- Make all definition lists render without the \tightlist attribute.
function untightDefinitionList(blocks)
    for i, block in ipairs(blocks) do
        if block[1][1] ~= nil and block[1][1].t == 'Plain' then
            blocks[i][1][1] = pandoc.Para(block[1][1].content)
        end
    end

    return blocks
end

function DefinitionList(el)
    el.content = pandoc.List.map(el.content, untightDefinitionList)
    return el
end

-- Make all non-definition lists render without the \tightlist attribute.
function untightList(blocks)
    for i, block in ipairs(blocks) do
        if block.t == 'Plain' then
            blocks[i] = pandoc.Para(block.content)
        end
    end

    return blocks
end

function BulletList(el)
    el.content = pandoc.List.map(el.content, untightList)
    return el
end

function OrderedList(el)
    el.content = pandoc.List.map(el.content, untightList)
    --el.listAttributes.style = "DefaultStyle"
    --el.listAttributes.delimiter =
    return el
end
