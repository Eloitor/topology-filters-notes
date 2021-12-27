local List = require 'pandoc.List'

lean_web_editor_url = "https://leanprover-community.github.io/lean-web-editor/#code="
current_code = ""

function CodeBlock(block)
    function encodeChar(chr)
        return string.format("%%%02X",string.byte(chr))
    end
     
    function encodeString(str)
        local output, t = string.gsub(str,"[^%w]",encodeChar)
        return output
    end

    if block.classes[1] == "lean" then

        local old_code = current_code
        local skip_code = false
        local hide_code = false
        link_code = current_code .. block.text

        for index, value in ipairs(block.classes) do
            if value == "reset" then
                old_code = ""
            end
            if value == "skip" then
                skip_code = true
            end
            if value == "hide" then
                hide_code = true
            end
        end

        current_code = old_code .. encodeString(block.text  .. "\n\n")

        if not skip_code then
            old_code = current_code
        end
        
        construct_link = lean_web_editor_url .. current_code
        -- If the code is skipped, we reset the current code
        current_code = old_code 

        if hide_code then
            return {}
        end

        local attr = pandoc.Attr("", {"try-me-link"})
        local try_me_link = pandoc.Link('Try me', construct_link, "", attr)
        return pandoc.Div({ pandoc.Para{ try_me_link}, block }, pandoc.Attr("", {"try-me-container"}))
    end
end

