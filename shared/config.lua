----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

config = config or {}

-- Logic settings
config.logic = {
    chances = {
        ['trick'] = 90,
        ['treat'] = 10
    },
    tricks = {
        ['set_on_fire'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'set_player_on_fire'
            },
        },
        ['set_as_drunk'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'set_as_drunk'
            },
            ['params'] = {
                ['duration'] = 30,
                ['disable_screen_effects'] = false,
            }
        },
        ['rain_chickens'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'rain_chickens'
            },
            ['params'] = {
                ['duration'] = 30,
                ['amount'] = 20,
            }
        },
        ['random_angry_ped'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'random_angry_ped'
            },
            ['params'] = {
                ['peds'] = {
                    'u_m_y_imporage', 'u_m_m_jesus_01', 'u_m_y_mani', 's_m_m_mariachi_01', 
                    's_m_y_mime', 's_m_m_movalien_01', 's_m_m_movspace_01', 'cs_orleans',
                    'u_m_y_pogo_01', 'ig_priest', 'u_m_y_rsranger_01', 's_m_m_strperf_01',
                    'u_f_y_corpse_01'
                },
            }
        },
        ['random_teleport'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'random_teleport'
            },
            ['params'] = {
                ['teleport_back'] = true,
                ['duration'] = 30,
                ['locations'] = { 
                    vector4(239.1, 5576.17, 602.16, 89.01), 
                 },
            }
        },
        ['jack_o_lantern'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'jack_o_lantern'
            },
            ['params'] = {
                ['duration'] = 30,
                ['models'] = {
                    'reh_prop_reh_lantern_pk_01a',
                    'reh_prop_reh_lantern_pk_01b',
                    'reh_prop_reh_lantern_pk_01c'
                }
            }
        }
        
    },
    treats = {
        ['super_speed'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'super_speed'
            },
            ['params'] = {
                ['duration'] = 30,
                ['speed_multiplier'] = 1.49,
            }
        },
        ['super_jump'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'super_jump'
            },
            ['params'] = {
                ['duration'] = 30,
            }
        },
        ['super_strength'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'super_strength'
            },
            ['params'] = {
                ['duration'] = 30,
                ['strength_multiplier'] = 150.0,
            }
        },
        ['invisibility'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'invisibility'
            },
            ['params'] = {
                ['duration'] = 30,
            }
        },
        ['invincibility'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'invincibility'
            },
            ['params'] = {
                ['duration'] = 30,
            }
        },
        ['fireworks_show'] = {
            ['enabled'] = true,
            ['action'] = {
                ['type'] = 'function',
                ['execute'] = 'fireworks_show'
            },
            ['params'] = {
                ['duration'] = 30,
            }
        },
    }
}
