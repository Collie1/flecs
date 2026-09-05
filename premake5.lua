workspace "flecs"
    configurations { "Debug", "Release", "Distribution" }
    language "C"
    cdialect "C11"

    flags { "MultiProcessorCompile" }

    newoption {
        trigger = "flecs-static",
        description = "Build static flecs library",
        default = "On"
    }

    newoption {
        trigger = "flecs-shared",
        description = "Build shared flecs library",
        default = "On"
    }

    newoption {
        trigger = "flecs-pic",
        description = "Compile with position independent code",
        default = "On"
    }

    newoption {
        trigger = "flecs-tests",
        description = "Build flecs tests",
        default = "Off"
    }


    ----------------------------------------------------------------
    -- Common settings
    ----------------------------------------------------------------

    local function flecs_common()
        files {
            "include/**.h",
            "include/**.hpp",
            "include/**.inl",
            "src/**.c"
        }

        includedirs {
            "include"
        }

        filter "configurations:Debug"
            symbols "On"
            optimize "Off"

        filter "configurations:Release"
            symbols "On"
            optimize "Speed"

        filter "configurations:Distribution"
            symbols "Off"
            optimize "Speed"
            

        filter {}

        -- Position independent code
        if _OPTIONS["flecs-pic"] ~= "Off" then
            filter "system:linux"
                pic "On"

            filter "system:macosx"
                pic "On"

            filter "system:android"
                pic "On"

            filter {}
        end

        -- Windows
        filter "system:windows"
            links {
                "wsock32",
                "ws2_32",
                "dbghelp"
            }

        -- Linux
        filter "system:linux"
            links {
                "pthread"
            }

        filter {}
    end


    ----------------------------------------------------------------
    -- Shared library
    ----------------------------------------------------------------

    if _OPTIONS["flecs-shared"] ~= "Off" then
        project "flecs"
            kind "SharedLib"
            targetname "flecs"

            flecs_common()
    end


    ----------------------------------------------------------------
    -- Static library
    ----------------------------------------------------------------

    if _OPTIONS["flecs-static"] ~= "Off" then
        project "flecs_static"
            kind "StaticLib"
            targetname "flecs_static"

            flecs_common()

            defines {
                "flecs_STATIC"
            }
    end


    ----------------------------------------------------------------
    -- Tests
    ----------------------------------------------------------------

    if _OPTIONS["flecs-tests"] == "On" then
        project "flecs_tests"
            kind "ConsoleApp"
            language "C"

            files {
                "test/**.c",
                "test/**.h"
            }

            includedirs {
                "include",
                "test"
            }

            if _OPTIONS["flecs-static"] ~= "Off" then
                links {
                    "flecs_static"
                }
            elseif _OPTIONS["flecs-shared"] ~= "Off" then
                links {
                    "flecs"
                }
            end

            filter "system:windows"
                links {
                    "wsock32",
                    "ws2_32",
                    "dbghelp"
                }

            filter "system:linux"
                links {
                    "pthread"
                }

            filter {}
    end

