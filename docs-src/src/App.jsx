import { useState, useEffect, useRef } from 'react';

// Static documentation content definitions
const SIDEBAR_ITEMS = {
  gettingStarted: [
    { id: "introduction", name: "Introduction", icon: "fa-circle-info", path: "#/introduction" },
    { id: "getting-started", name: "Quick Start", icon: "fa-rocket", path: "#/getting-started" },
    { id: "features", name: "Features", icon: "fa-star", path: "#/features" }
  ],
  core: [
    { id: "CreateWindow", name: "CreateWindow", icon: "fa-window-maximize", path: "#/CreateWindow" },
    { id: "Notify", name: "Notify", icon: "fa-bell", path: "#/Notify" },
    { id: "SetWatermark", name: "SetWatermark", icon: "fa-chart-line", path: "#/SetWatermark" },
    { id: "CreateControlHUD", name: "CreateControlHUD", icon: "fa-sliders", path: "#/CreateControlHUD" },
    { id: "AddCleanup", name: "AddCleanup", icon: "fa-trash-can", path: "#/AddCleanup" },
    { id: "CreateTimer", name: "CreateTimer", icon: "fa-clock", path: "#/CreateTimer" },
    { id: "RegisterIcon", name: "RegisterIcon", icon: "fa-image", path: "#/RegisterIcon" },
    { id: "RegisterIconPack", name: "RegisterIconPack", icon: "fa-images", path: "#/RegisterIconPack" },
  ],
  layout: [
    { id: "CreateSection", name: "CreateSection", icon: "fa-grip-lines", path: "#/CreateSection" },
    { id: "CreateTab", name: "CreateTab", icon: "fa-folder-open", path: "#/CreateTab" },
    { id: "CreateHBar", name: "CreateHBar", icon: "fa-grip", path: "#/CreateHBar" },
    { id: "CreateVBar", name: "CreateVBar", icon: "fa-ellipsis-vertical", path: "#/CreateVBar" },
  ],
  components: [
    { id: "CreateButton", name: "CreateButton", icon: "fa-square-check", path: "#/CreateButton" },
    { id: "CreateColorPicker", name: "CreateColorPicker", icon: "fa-palette", path: "#/CreateColorPicker" },
    { id: "CreateDivider", name: "CreateDivider", icon: "fa-minus", path: "#/CreateDivider" },
    { id: "CreateDropdown", name: "CreateDropdown", icon: "fa-caret-down", path: "#/CreateDropdown" },
    { id: "CreateInput", name: "CreateInput", icon: "fa-keyboard", path: "#/CreateInput" },
    { id: "CreateKeybind", name: "CreateKeybind", icon: "fa-keyboard", path: "#/CreateKeybind" },
    { id: "CreateLogger", name: "CreateLogger", icon: "fa-terminal", path: "#/CreateLogger" },
    { id: "CreateParagraph", name: "CreateParagraph", icon: "fa-paragraph", path: "#/CreateParagraph" },
    { id: "CreatePlayerList", name: "CreatePlayerList", icon: "fa-users", path: "#/CreatePlayerList" },
    { id: "CreateSlider", name: "CreateSlider", icon: "fa-sliders", path: "#/CreateSlider" },
    { id: "CreateTargetBody", name: "CreateTargetBody", icon: "fa-child", path: "#/CreateTargetBody" },
    { id: "CreateToggle", name: "CreateToggle", icon: "fa-toggle-on", path: "#/CreateToggle" },
  ],
  modules: [
    { id: "profile", name: "Profile", icon: "fa-user-circle", path: "#/modules/profile" }
  ],
  examples: [
    { id: "full-script", name: "Full Script", icon: "fa-code", path: "#/examples/full-script" }
  ]
};

const STATIC_SEARCH_ITEMS = [
  {
    name: "Introduction",
    url: "#/introduction",
    group: "Getting Started",
    icon: "fa-circle-info",
    description: "Overview of MonoUI premium, modular Roblox UI library."
  },
  {
    name: "Quick Start",
    url: "#/getting-started",
    group: "Getting Started",
    icon: "fa-rocket",
    description: "Bootstrap loadstring and start executing MonoUI."
  },
  {
    name: "Features",
    url: "#/features",
    group: "Getting Started",
    icon: "fa-star",
    description: "List of primitive features and configuration saving."
  },
  {
    name: "Full Script",
    url: "#/examples/full-script",
    group: "Examples",
    icon: "fa-code",
    description: "A complete working example using all major MonoUI features."
  },
  {
    name: "Profile Module",
    url: "#/modules/profile",
    group: "Modules",
    icon: "fa-user-circle",
    description: "Renders a player profile widget in the sidebar."
  }
];

// Helper to construct full script boilerplate
const generateFullContextExample = (funcName, basicExample) => {
  const loadstringLine = '-- Load the MonoUI Library\nlocal MonoUI = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Release.luau"))()';
  
  if (funcName === "CreateWindow" || ["Notify", "SetWatermark", "CreateControlHUD"].includes(funcName)) {
    return `${loadstringLine}\n\n${basicExample}`;
  }
  
  if (["AddCleanup", "CreateTimer", "CreateTab"].includes(funcName)) {
    return `${loadstringLine}\n\n-- Create the main Window\nlocal window = MonoUI.CreateWindow({\n    Title      = "mono ui",\n    ConfigName = "mono_config",\n    AutoSave   = true,\n})\n\n${basicExample}`;
  }
  
  if (basicExample.includes("local MonoUI")) {
    return basicExample;
  }
  
  if (funcName === "CreateVBar") {
    return `${loadstringLine}\n\n-- Create the main Window\nlocal window = MonoUI.CreateWindow({\n    Title      = "mono ui",\n    ConfigName = "mono_config",\n    AutoSave   = true,\n})\n\n-- Create a Tab\nlocal tab = window:CreateTab({ text = "Main", icon = "home" })\n\n-- Create a Horizontal Column stack (HBar)\nlocal hbar = tab:CreateHBar()\n\n-- Create the VBar\n${basicExample}`;
  }
  
  return `${loadstringLine}\n\n-- Create the main Window\nlocal window = MonoUI.CreateWindow({\n    Title      = "mono ui",\n    ConfigName = "mono_config",\n    AutoSave   = true,\n})\n\n-- Create a Tab\nlocal tab = window:CreateTab({ text = "Main", icon = "home" })\n\n-- Create the component\n${basicExample}`;
};

// Reusable CodeBlock component with Copy state
const CodeBlock = ({ code, language = "lua" }) => {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(code).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }).catch(err => {
      console.error("Failed to copy code: ", err);
    });
  };

  return (
    <div className="code-container">
      <div className="code-header">
        <span className="code-lang">{language === "lua" ? "Lua" : language}</span>
        <button className={`copy-btn ${copied ? 'copied' : ''}`} onClick={handleCopy}>
          {copied ? (
            <>
              <i className="fa-solid fa-check"></i> Copied!
            </>
          ) : (
            <>
              <i className="fa-regular fa-copy"></i> Copy
            </>
          )}
        </button>
      </div>
      <pre>
        <code className={`language-${language}`}>{code}</code>
      </pre>
    </div>
  );
};

export default function App() {
  const [hash, setHash] = useState(window.location.hash || "#/");
  const [apiData, setApiData] = useState({});
  const [latestVersion, setLatestVersion] = useState("v1.5");
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState([]);
  const [searchIndex, setSearchIndex] = useState(-1);
  const [searchFocused, setSearchFocused] = useState(false);
  const dropdownRef = useRef(null);
  const searchInputRef = useRef(null);

  // Sync hash routing
  useEffect(() => {
    const handleHashChange = () => {
      const currentHash = window.location.hash || "#/";
      setHash(currentHash);

      // Handle scrolling on landing sub-sections
      if (["#/", "#/introduction", "#/getting-started", "#/features"].includes(currentHash)) {
        setTimeout(() => {
          let elementId = "introduction";
          if (currentHash === "#/getting-started") elementId = "getting-started";
          else if (currentHash === "#/features") elementId = "features";

          const element = document.getElementById(elementId);
          if (element) {
            element.scrollIntoView({ behavior: "smooth" });
          }
        }, 100);
      } else {
        // Scroll content container to top on new page load
        const mainEl = document.querySelector(".content-container");
        if (mainEl) mainEl.scrollTop = 0;
      }
    };

    window.addEventListener("hashchange", handleHashChange);
    // Initial call to scroll if landing hash is selected at start
    handleHashChange();

    return () => window.removeEventListener("hashchange", handleHashChange);
  }, []);

  // Fetch dump.json
  useEffect(() => {
    fetch("./dump.json")
      .then(res => res.json())
      .then(data => {
        setApiData(data);
      })
      .catch(err => {
        console.warn("Could not fetch dump.json, fallback to empty: ", err);
      });
  }, []);

  // Fetch GitHub release tag
  useEffect(() => {
    fetch("https://api.github.com/repos/BloodLetters/Mono-UI/releases/latest")
      .then(res => {
        if (res.ok) return res.json();
        throw new Error();
      })
      .then(data => {
        if (data && data.tag_name) {
          setLatestVersion(data.tag_name);
        }
      })
      .catch(() => {
        // Fallback already v1.5
      });
  }, []);

  // Trigger Prism highlighting on content render
  useEffect(() => {
    if (window.Prism) {
      window.Prism.highlightAll();
    }
  }, [hash, apiData]);

  // Handle outside click to close search dropdown
  useEffect(() => {
    const handleOutsideClick = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target) &&
          searchInputRef.current && !searchInputRef.current.contains(e.target)) {
        setSearchFocused(false);
      }
    };
    document.addEventListener("mousedown", handleOutsideClick);
    return () => document.removeEventListener("mousedown", handleOutsideClick);
  }, []);

  // Setup search data list
  const getSearchData = () => {
    const dynamicItems = Object.entries(apiData).map(([funcName, funcData]) => {
      let icon = "fa-cube";
      if (funcData.type === "core") {
        if (funcName === "CreateWindow") icon = "fa-window-maximize";
        else if (funcName === "Notify") icon = "fa-bell";
        else if (funcName === "SetWatermark") icon = "fa-chart-line";
        else if (funcName === "CreateControlHUD") icon = "fa-sliders";
        else if (funcName === "AddCleanup") icon = "fa-trash-can";
        else if (funcName === "CreateTimer") icon = "fa-clock";
        else if (funcName === "RegisterIcon") icon = "fa-image";
        else if (funcName === "RegisterIconPack") icon = "fa-images";
      } else if (funcData.type === "layout") {
        if (funcName === "CreateSection") icon = "fa-grip-lines";
        else if (funcName === "CreateTab") icon = "fa-folder-open";
        else if (funcName === "CreateHBar") icon = "fa-grip";
        else if (funcName === "CreateVBar") icon = "fa-ellipsis-vertical";
      } else if (funcData.type === "components") {
        if (funcName === "CreateButton") icon = "fa-square-check";
        else if (funcName === "CreateColorPicker") icon = "fa-palette";
        else if (funcName === "CreateDivider") icon = "fa-minus";
        else if (funcName === "CreateDropdown") icon = "fa-caret-down";
        else if (funcName === "CreateInput") icon = "fa-keyboard";
        else if (funcName === "CreateKeybind") icon = "fa-keyboard";
        else if (funcName === "CreateLogger") icon = "fa-terminal";
        else if (funcName === "CreateParagraph") icon = "fa-paragraph";
        else if (funcName === "CreatePlayerList") icon = "fa-users";
        else if (funcName === "CreateSlider") icon = "fa-sliders";
        else if (funcName === "CreateTargetBody") icon = "fa-child";
        else if (funcName === "CreateToggle") icon = "fa-toggle-on";
      }

      return {
        name: funcName,
        url: `#/${funcName}`,
        group: funcData.label,
        icon: icon,
        description: funcData.description
      };
    });

    return [...STATIC_SEARCH_ITEMS, ...dynamicItems];
  };

  // Perform search filtering
  const handleSearchInput = (e) => {
    const val = e.target.value;
    setSearchQuery(val);
    setSearchIndex(-1);

    if (val.trim() === "") {
      setSearchResults([]);
      return;
    }

    const query = val.toLowerCase().trim();
    const searchData = getSearchData();
    const filtered = searchData.filter(item => 
      item.name.toLowerCase().includes(query) ||
      item.description.toLowerCase().includes(query) ||
      item.group.toLowerCase().includes(query)
    );

    setSearchResults(filtered.slice(0, 8));
  };

  // Search input keydown handler (keyboard nav)
  const handleSearchKeyDown = (e) => {
    if (searchResults.length === 0) return;

    if (e.key === "ArrowDown") {
      e.preventDefault();
      setSearchIndex(prev => (prev + 1) % searchResults.length);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setSearchIndex(prev => (prev - 1 + searchResults.length) % searchResults.length);
    } else if (e.key === "Enter") {
      e.preventDefault();
      const index = searchIndex >= 0 ? searchIndex : 0;
      const selected = searchResults[index];
      if (selected) {
        window.location.hash = selected.url;
        setSearchFocused(false);
        setSearchQuery("");
        setSearchResults([]);
      }
    } else if (e.key === "Escape") {
      setSearchFocused(false);
      if (searchInputRef.current) searchInputRef.current.blur();
    }
  };

  // Determine current active page
  const getActiveTab = () => {
    if (hash === "#/" || hash.startsWith("#/introduction") || hash.startsWith("#/getting-started") || hash.startsWith("#/features")) {
      return "introduction";
    }
    const cleanRoute = hash.replace("#/", "");
    if (cleanRoute.startsWith("modules/")) return "profile";
    if (cleanRoute.startsWith("examples/")) return "full-script";
    return cleanRoute;
  };

  const activeTab = getActiveTab();

  // Check if target hash matches landing page sections
  const isLandingActive = (sectionId) => {
    if (sectionId === "introduction" && hash === "#/") return true;
    return hash === `#/${sectionId}`;
  };

  // Render navigation group items
  const renderNavItems = (items) => {
    return items.map((item) => {
      const isActive = activeTab === item.id;
      return (
        <a
          key={item.id}
          href={item.path}
          className={`nav-item ${isActive ? "active" : ""}`}
        >
          <i className={`fa-solid ${item.icon}`}></i>
          {item.name}
        </a>
      );
    });
  };

  return (
    <div>
      {/* Navbar */}
      <header className="navbar" id="navbar">
        <div className="nav-left">
          <div className="brand">
            <i className="fa-solid fa-shield-halved brand-logo"></i>
            <span className="brand-name">Mono<span>UI</span></span>
          </div>
          <span className="badge">{latestVersion}</span>
        </div>
        <div className="nav-right">
          <div className="search-wrapper">
            <i className="fa-solid fa-magnifying-glass search-icon"></i>
            <input
              type="text"
              id="doc-search"
              ref={searchInputRef}
              placeholder="Search docs..."
              value={searchQuery}
              onChange={handleSearchInput}
              onKeyDown={handleSearchKeyDown}
              onFocus={() => setSearchFocused(true)}
            />
            {/* Search Dropdown Overlay */}
            {searchFocused && (searchQuery.trim() !== "" || searchResults.length > 0) && (
              <div
                id="search-results-dropdown"
                className="search-results active"
                ref={dropdownRef}
              >
                {searchResults.length === 0 ? (
                  <div className="search-no-results">No results found</div>
                ) : (
                  searchResults.map((item, idx) => (
                    <a
                      key={idx}
                      href={item.url}
                      className={`search-result-item ${searchIndex === idx ? 'selected' : ''}`}
                      onClick={() => {
                        setSearchFocused(false);
                        setSearchQuery("");
                        setSearchResults([]);
                      }}
                    >
                      <div className="search-result-header">
                        <span className="search-result-title">
                          <i className={`fa-solid ${item.icon}`}></i>
                          <span>{item.name}</span>
                        </span>
                        <span className="search-result-group">{item.group}</span>
                      </div>
                      <div className="search-result-desc">{item.description}</div>
                    </a>
                  ))
                )}
              </div>
            )}
          </div>
          <a href="https://github.com/BloodLetters/Mono-UI" target="_blank" rel="noreferrer" className="github-link" id="github-link">
            <i className="fa-brands fa-github"></i> GitHub
          </a>
        </div>
      </header>

      <div className="main-layout">
        {/* Sidebar */}
        <aside className="sidebar" id="sidebar">
          <nav className="sidebar-nav">
            <div className="nav-group">
              <span className="group-title">Getting Started</span>
              <a href="#/introduction" className={`nav-item ${isLandingActive("introduction") ? "active" : ""}`}>
                <i className="fa-solid fa-circle-info"></i> Introduction
              </a>
              <a href="#/getting-started" className={`nav-item ${isLandingActive("getting-started") ? "active" : ""}`}>
                <i className="fa-solid fa-rocket"></i> Quick Start
              </a>
              <a href="#/features" className={`nav-item ${isLandingActive("features") ? "active" : ""}`}>
                <i className="fa-solid fa-star"></i> Features
              </a>
            </div>

            <div className="nav-group">
              <span className="group-title">Core</span>
              {renderNavItems(SIDEBAR_ITEMS.core)}
            </div>

            <div className="nav-group">
              <span className="group-title">Layout</span>
              {renderNavItems(SIDEBAR_ITEMS.layout)}
            </div>

            <div className="nav-group">
              <span className="group-title">Components</span>
              {renderNavItems(SIDEBAR_ITEMS.components)}
            </div>

            <div className="nav-group">
              <span className="group-title">Modules</span>
              {renderNavItems(SIDEBAR_ITEMS.modules)}
            </div>

            <div className="nav-group">
              <span className="group-title">Examples</span>
              {renderNavItems(SIDEBAR_ITEMS.examples)}
            </div>
          </nav>
        </aside>

        {/* Main Content Area */}
        <main className="content-container">
          
          {/* Landing / Getting Started Page */}
          {(hash === "#/" || hash.startsWith("#/introduction") || hash.startsWith("#/getting-started") || hash.startsWith("#/features")) && (
            <>
              {/* Introduction */}
              <section id="introduction" className="doc-section">
                <div className="breadcrumb">
                  <span className="current">Getting Started</span>
                </div>
                <div className="section-label">Overview</div>
                <h1>MonoUI Documentation</h1>
                <p className="lead-text">A premium, modular Roblox UI library with dark-mode aesthetics, auto-saving config, live search, and autoexec support.</p>
                <div className="alert note">
                  <i className="fa-solid fa-lightbulb alert-icon"></i>
                  <div>All interactive components automatically sync their values to the global config when modified. Use <code>flag</code> to identify each element.</div>
                </div>
              </section>

              {/* Quick Start */}
              <section id="getting-started" className="doc-section">
                <div className="breadcrumb">
                  <span className="link-span" onClick={() => window.location.hash = "#/introduction"}>Getting Started</span>
                  <span className="sep">›</span>
                  <span className="current">Quick Start</span>
                </div>
                <div className="section-label">Setup</div>
                <h2>Quick Start</h2>
                <p>Paste the loadstring bootstrapper into your script to initialize MonoUI.</p>
                <CodeBlock code='local MonoUI = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Release.luau"))()' />
              </section>

              {/* Features */}
              <section id="features" class="doc-section">
                <div className="breadcrumb">
                  <span className="link-span" onClick={() => window.location.hash = "#/introduction"}>Getting Started</span>
                  <span className="sep">›</span>
                  <span className="current">Features</span>
                </div>
                <div className="section-label">Overview</div>
                <h2>Features</h2>
                <p>MonoUI ships with a full suite of UI primitives and productivity features out of the box.</p>
                <div className="features-grid">
                  <div className="feature-card">
                    <i className="fa-solid fa-magnifying-glass feature-icon"></i>
                    <h3>Live Search</h3>
                    <p>Built-in search bar filters components in real-time as you type.</p>
                  </div>
                  <div className="feature-card">
                    <i className="fa-solid fa-floppy-disk feature-icon"></i>
                    <h3>Auto Save & Load</h3>
                    <p>Serializes all component states including Color3 and KeyCodes.</p>
                  </div>
                  <div className="feature-card">
                    <i className="fa-solid fa-rotate feature-icon"></i>
                    <h3>AutoExec</h3>
                    <p>Queues script re-execution on server teleport automatically.</p>
                  </div>
                  <div className="feature-card">
                    <i className="fa-solid fa-arrows-to-eye feature-icon"></i>
                    <h3>Control HUD</h3>
                    <p>Draggable floating quick-toggle HUD with icon-only buttons.</p>
                  </div>
                </div>
              </section>
            </>
          )}

          {/* Modules: Profile Page */}
          {hash === "#/modules/profile" && (
            <>
              {/* Modules Overview */}
              <section id="modules-overview" className="doc-section">
                <div className="breadcrumb">
                  <span className="current">Modules</span>
                </div>
                <div className="section-label">Overview</div>
                <h2>Modules</h2>
                <p>Modules are optional add-ons that enhance the MonoUI window with extra UI components. They are <strong>off by default</strong> and must be activated manually before creating the window.</p>
                <div className="alert note">
                  <i className="fa-solid fa-lightbulb alert-icon"></i>
                  <div>You must declare <code>MonoUI.module</code> <strong>before</strong> calling <code>MonoUI.CreateWindow()</code> for modules to take effect.</div>
                </div>
                <CodeBlock code={`-- Declare which modules to activate BEFORE creating the window
MonoUI.module = {
    profile = true,
}

local window = MonoUI.CreateWindow({
    Title    = "mono ui",
    Subtitle = "premium modular library",
    Size     = UDim2.fromOffset(600, 400),
})`} />
              </section>

              {/* Profile Module */}
              <section id="module-profile" className="doc-section">
                <div className="breadcrumb">
                  <span className="link-span" onClick={() => window.location.hash = "#/modules/profile"}>Modules</span>
                  <span className="sep">›</span>
                  <span className="current">Profile</span>
                </div>
                <div className="section-label">Module API</div>
                <h2>Profile</h2>
                <p>Renders a player profile widget at the bottom of the sidebar. Displays the local player's avatar (round headshot), display name, and username. Automatically reads <code>Players.LocalPlayer</code> — no extra setup needed.</p>

                <div className="alert note">
                  <i className="fa-solid fa-lightbulb alert-icon"></i>
                  <div>All fields are optional. If omitted, the module reads the live local player data at runtime.</div>
                </div>

                <h3>Options</h3>
                <table className="params-table">
                  <thead>
                    <tr>
                      <th>Field</th>
                      <th>Type</th>
                      <th>Default</th>
                      <th>Description</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>CustomName</td>
                      <td><span className="type type-string">string</span></td>
                      <td><code>player.DisplayName</code></td>
                      <td>Override the display name shown in the profile widget.</td>
                    </tr>
                    <tr>
                      <td>CustomUsername</td>
                      <td><span className="type type-string">string</span></td>
                      <td><code>"@" .. player.Name</code></td>
                      <td>Override the username handle (shown in muted colour below the name).</td>
                    </tr>
                    <tr>
                      <td>CustomAvatar</td>
                      <td><span className="type type-string">string</span></td>
                      <td><code>rbxthumb AvatarHeadShot</code></td>
                      <td>A custom asset/URL to use as the avatar image instead of the auto-generated headshot thumbnail.</td>
                    </tr>
                    <tr>
                      <td>Height</td>
                      <td><span className="type type-number">number</span></td>
                      <td><code>48</code></td>
                      <td>Height in pixels of the profile footer area.</td>
                    </tr>
                  </tbody>
                </table>

                <h3>Activation</h3>
                <CodeBlock code={`-- Enable before CreateWindow
MonoUI.module = {
    profile = true,
}

local window = MonoUI.CreateWindow({
    Title    = "mono ui",
    Subtitle = "premium modular library",
    Size     = UDim2.fromOffset(600, 400),
})`} />
              </section>
            </>
          )}

          {/* Examples: Full Script Page */}
          {hash === "#/examples/full-script" && (
            <section id="full-code" className="doc-section">
              <div className="breadcrumb">
                <span className="current">Examples</span>
                <span className="sep">›</span>
                <span className="current">Full Script</span>
              </div>
              <div className="section-label">Examples</div>
              <h2>Full Script</h2>
              <p>A complete working example using all major MonoUI features.</p>
              <CodeBlock code={`local MonoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/mono-ui/main/dist/mono-ui.luau"))()

MonoUI.SetWatermark({ visible = true, text = "MonoUI Premium" })

local window = MonoUI.CreateWindow({
    Title      = "mono ui",
    Subtitle   = "premium modular library",
    Size       = UDim2.fromOffset(600, 400),
    Icon       = "shield",
    ConfigName = "my_config",
    AutoSave   = true,
    AutoExec   = true,
})

-- Console tab
local consoleTab = window:CreateTab({ text = "Console", icon = "terminal" })
consoleTab:CreateSection({ text = "System Logs" })
local logger = consoleTab:CreateLogger({ text = "Output", height = 280 })

-- Combat tab
local combatTab = window:CreateTab({ text = "Combat", icon = "swords" })
combatTab:CreateSection({ text = "Aimbot" })
combatTab:CreateToggle({
    text = "Silent Aim", default = false, flag = "silent_aim",
    callback = function(v) logger:Log("INFO", "Silent Aim: " .. tostring(v)) end,
})
combatTab:CreateSlider({
    text = "FOV", min = 10, max = 200, default = 90, flag = "fov",
    callback = function(v) logger:Log("INFO", "FOV: " .. v) end,
})

logger:Log("SUCCESS", "All tabs loaded.")`} />
            </section>
          )}

          {/* Dynamic API Documentation Page */}
          {Object.keys(apiData).length > 0 && apiData[activeTab] && (
            <section id={activeTab.toLowerCase().replace('create', '')} className="doc-section">
              <div className="breadcrumb">
                <span className="link-span" onClick={() => window.location.hash = "#/introduction"}>
                  {apiData[activeTab].type.charAt(0).toUpperCase() + apiData[activeTab].type.slice(1)}
                </span>
                <span className="sep">›</span>
                <span className="current">{activeTab}</span>
              </div>
              <div className="section-label">{apiData[activeTab].label}</div>
              <h2>{activeTab}</h2>
              <p>{apiData[activeTab].description}</p>

              {apiData[activeTab].arguments && apiData[activeTab].arguments.length > 0 && (
                <>
                  <table className="params-table">
                    <thead>
                      <tr>
                        <th>Argument</th>
                        <th>Type</th>
                        <th>Description</th>
                      </tr>
                    </thead>
                    <tbody>
                      {apiData[activeTab].arguments.map((arg, idx) => {
                        let typeClass = "type-string";
                        const argType = arg.type.toLowerCase();
                        if (argType.includes("boolean")) typeClass = "type-boolean";
                        else if (argType.includes("number")) typeClass = "type-number";
                        else if (argType.includes("function")) typeClass = "type-function";
                        else if (argType.includes("table") || argType.includes("array")) typeClass = "type-table";
                        else if (argType.includes("color3")) typeClass = "type-color3";
                        else if (argType.includes("keycode")) typeClass = "type-keycode";

                        return (
                          <tr key={idx}>
                            <td>{arg.name}</td>
                            <td><span className={`type ${typeClass}`}>{arg.type}</span></td>
                            <td>{arg.description}</td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </>
              )}

              <h3>Code Snippet</h3>
              <CodeBlock code={apiData[activeTab].example} />

              <h3>Complete Script Usage</h3>
              <CodeBlock code={generateFullContextExample(activeTab, apiData[activeTab].example)} />
            </section>
          )}

        </main>
      </div>

      <footer className="footer">
        &copy; 2026 MonoUI — MIT License
      </footer>
    </div>
  );
}
