import { useState, useEffect, useRef } from 'react';

// Static documentation content definitions
const SIDEBAR_ITEMS = {
  gettingStarted: [
    { id: "introduction", name: "Introduction", icon: "fa-circle-info", path: "#/introduction" },
    { id: "getting-started", name: "Quick Start", icon: "fa-rocket", path: "#/getting-started" },
    { id: "features", name: "Features", icon: "fa-star", path: "#/features" },
    { id: "global-env", name: "Global Environment", icon: "fa-earth-americas", path: "#/global-env" }
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
    { id: "profile", name: "Profile", icon: "fa-user-circle", path: "#/modules/profile" },
    { id: "vanity", name: "Vanity", icon: "fa-eye", path: "#/modules/vanity" },
    { id: "lead", name: "Lead", icon: "fa-crosshairs", path: "#/modules/lead" }
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
  },
  {
    name: "Vanity Module",
    url: "#/modules/vanity",
    group: "Modules",
    icon: "fa-eye",
    description: "Modular ESP system — Box, Name, Health Bar, Highlight/Cham, Visibility Colors."
  },
  {
    name: "Lead Module",
    url: "#/modules/lead",
    group: "Modules",
    icon: "fa-crosshairs",
    description: "Flexible combat module — Aimbot, Trigger Bot, Silent Aim with custom character support."
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
    if (cleanRoute === "modules/vanity") return "vanity";
    if (cleanRoute === "modules/lead") return "lead";
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

          {/* Getting Started: Global Environment Page */}
          {hash === "#/global-env" && (
            <section id="global-env" className="doc-section">
              <div className="breadcrumb">
                <span className="current">Getting Started</span>
                <span className="sep">›</span>
                <span className="current">Global Environment</span>
              </div>
              <div className="section-label">Environment</div>
              <h2>Global Environment</h2>
              <p>MonoUI automatically registers a global environment table <code>getgenv().monoui</code>. This allows scripts to dynamically read, query, and modify properties of the active UI from anywhere in the execution context.</p>

              <h3>Available Properties</h3>
              <div className="table-container">
                <table className="doc-table">
                  <thead>
                    <tr><th>Property</th><th>Type</th><th>Access</th><th>Description</th></tr>
                  </thead>
                  <tbody>
                    <tr><td><code>title</code></td><td>string</td><td>Read & Write</td><td>Gets or sets the main window title.</td></tr>
                    <tr><td><code>subtitle</code></td><td>string</td><td>Read & Write</td><td>Gets or sets the main window subtitle.</td></tr>
                    <tr><td><code>visible</code></td><td>boolean</td><td>Read & Write</td><td>Gets or sets the window visibility (opens/minimizes).</td></tr>
                    <tr><td><code>flags</code></td><td>table</td><td>Read Only</td><td>Retrieves the key-value dictionary of all component configurations.</td></tr>
                    <tr><td><code>components</code></td><td>table</td><td>Read Only</td><td>Retrieves the dictionary of instantiated components.</td></tr>
                    <tr><td><code>activeTab</code></td><td>string</td><td>Read Only</td><td>Gets the name of the currently visible tab.</td></tr>
                    <tr><td><code>window</code></td><td>table</td><td>Read Only</td><td>Gets the raw active window object.</td></tr>
                    <tr><td><code>close()</code></td><td>function</td><td>Execute</td><td>Closes and completely destroys the window.</td></tr>
                  </tbody>
                </table>
              </div>

              <h3>Code Examples</h3>
              
              <h4>Read & Modify Title/Subtitle</h4>
              <CodeBlock code={`local MonoUI = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Release.luau"))()
local window = MonoUI.CreateWindow({
    Title = "Original Title",
    Subtitle = "Original Subtitle"
})

task.wait(2)
-- Read properties
print(getgenv().monoui.title) -- Prints "Original Title"

-- Update properties dynamically
getgenv().monoui.title = "Updated Title"
getgenv().monoui.subtitle = "Updated Subtitle"
`} />

              <h4>Change Visibility & Close UI</h4>
              <CodeBlock code={`-- Hide the UI
getgenv().monoui.visible = false

task.wait(1)
-- Show the UI again
getgenv().monoui.visible = true

task.wait(1)
-- Destroy/Close the UI completely
getgenv().monoui.close()
`} />
            </section>
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

          {/* Modules: Vanity Page */}
          {hash === "#/modules/vanity" && (
            <>
              <section id="vanity-module" className="doc-section">
                <div className="breadcrumb">
                  <span className="link-span" onClick={() => window.location.hash = "#/modules/profile"}>Modules</span>
                  <span className="sep">›</span>
                  <span className="current">Vanity</span>
                </div>
                <div className="section-label">Module</div>
                <h2>Vanity ESP</h2>
                <p>Vanity is a <strong>modular ESP system</strong> for Roblox — Box, Name, Health Bar, Highlight/Cham, and Visibility Colors. Zero external dependencies, uses only Roblox built-in APIs and <code>Drawing</code> objects.</p>

                <div className="alert note">
                  <i className="fa-solid fa-lightbulb alert-icon"></i>
                  <div>Vanity is a standalone module — <strong>no MonoUI window required</strong>. You can use it independently or pair it with MonoUI toggles/sliders for a full GUI experience.</div>
                </div>

                <h3>Quick Start</h3>
                <CodeBlock code={`local Vanity = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Vanity.luau"))()

local esp = Vanity.new({
    BoxEnabled = true,
    NameEnabled = true,
    HealthEnabled = true,
    HighlightEnabled = false,
    VisibilityColor = false,
    MaxDistance = 1000,
})

-- ESP runs automatically every RenderStepped`} />

                <h3>API</h3>
                <h4><code>Vanity.new(options)</code></h4>
                <p>Creates and starts the ESP system. Accepts an optional options table.</p>

                <h4>Toggles</h4>
                <table className="params-table">
                  <thead>
                    <tr><th>Option</th><th>Type</th><th>Default</th><th>Description</th></tr>
                  </thead>
                  <tbody>
                    <tr><td>BoxEnabled</td><td><span className="type type-boolean">boolean</span></td><td><code>false</code></td><td>2D box around players</td></tr>
                    <tr><td>NameEnabled</td><td><span className="type type-boolean">boolean</span></td><td><code>false</code></td><td>Player name + distance above box</td></tr>
                    <tr><td>HealthEnabled</td><td><span className="type type-boolean">boolean</span></td><td><code>false</code></td><td>Health bar on left side of box</td></tr>
                    <tr><td>HighlightEnabled</td><td><span className="type type-boolean">boolean</span></td><td><code>false</code></td><td>3D highlight/cham on character</td></tr>
                    <tr><td>MaxDistance</td><td><span className="type type-number">number</span></td><td><code>1000</code></td><td>Max render distance (studs)</td></tr>
                    <tr><td>VisibilityColor</td><td><span className="type type-boolean">boolean</span></td><td><code>false</code></td><td>Highlight turns visible/invisible colors</td></tr>
                  </tbody>
                </table>

                <h4>Visual Customization</h4>
                <table className="params-table">
                  <thead>
                    <tr><th>Option</th><th>Type</th><th>Default</th><th>Description</th></tr>
                  </thead>
                  <tbody>
                    <tr><td>BoxColor</td><td><span className="type type-color3">Color3</span></td><td><code>(160,160,160)</code></td><td>Box outline color</td></tr>
                    <tr><td>BoxOutlineColor</td><td><span className="type type-color3">Color3</span></td><td><code>(60,60,60)</code></td><td>Box outer outline color</td></tr>
                    <tr><td>NameColor</td><td><span className="type type-color3">Color3</span></td><td><code>(255,255,255)</code></td><td>Name text color</td></tr>
                    <tr><td>NameSize</td><td><span className="type type-number">number</span></td><td><code>13</code></td><td>Name text size</td></tr>
                    <tr><td>HighlightColor</td><td><span className="type type-color3">Color3</span></td><td><code>(0,162,255)</code></td><td>Highlight fill color</td></tr>
                    <tr><td>VisibleColor</td><td><span className="type type-color3">Color3</span></td><td><code>(255,230,0)</code></td><td>Highlight color when visible</td></tr>
                  </tbody>
                </table>

                <h4>Custom Player Models</h4>
                <p>For non-standard R6/R15 characters, you can customize part names, offsets, and health class:</p>
                <table className="params-table">
                  <thead>
                    <tr><th>Option</th><th>Type</th><th>Default</th><th>Description</th></tr>
                  </thead>
                  <tbody>
                    <tr><td>RootPart</td><td><span className="type type-string">string | function</span></td><td><code>"HumanoidRootPart"</code></td><td>Part name or <code>function(char) =&gt; BasePart</code></td></tr>
                    <tr><td>HeadPart</td><td><span className="type type-string">string | function</span></td><td><code>"Head"</code></td><td>Part name or <code>function(char) =&gt; BasePart</code></td></tr>
                    <tr><td>HealthClass</td><td><span className="type type-string">string</span></td><td><code>"Humanoid"</code></td><td>Class name for health object</td></tr>
                    <tr><td>BoxTopOffset</td><td><span className="type type-vector3">Vector3</span></td><td><code>(0, 3, 0)</code></td><td>Offset from RootPart for box top</td></tr>
                    <tr><td>BoxBottomOffset</td><td><span className="type type-vector3">Vector3</span></td><td><code>(0, -3.5, 0)</code></td><td>Offset from RootPart for box bottom</td></tr>
                    <tr><td>IsValid</td><td><span className="type type-function">function</span></td><td><code>nil</code></td><td>Custom validity: <code>function(char) =&gt; bool</code></td></tr>
                  </tbody>
                </table>

                <h3>Custom Model Example</h3>
                <CodeBlock code={`local esp = Vanity.new({
    BoxEnabled = true,
    NameEnabled = true,

    -- NPC dengan part "Torso" bukan "HumanoidRootPart"
    RootPart = "Torso",

    -- Function lookup untuk head
    HeadPart = function(char)
        return char:FindFirstChild("Cabeza")
            or char:FindFirstChild("Head")
    end,

    -- Custom health class
    HealthClass = "MonsterHealth",

    -- Model lebih besar
    BoxTopOffset = Vector3.new(0, 6, 0),
    BoxBottomOffset = Vector3.new(0, -7, 0),

    -- Custom validity untuk NPC tanpa Humanoid
    IsValid = function(char)
        return char:FindFirstChild("IsNPC") ~= nil
    end,
})`} />

                <h4><code>esp:UpdateOptions(options)</code></h4>
                <p>Update settings at runtime — ideal for GUI toggles/sliders. Only pass the keys you want to change.</p>

                <CodeBlock code={`esp:UpdateOptions({
    BoxEnabled = false,
    HighlightEnabled = true,
    MaxDistance = 500,
})`} />

                <h4><code>esp:Destroy()</code></h4>
                <p>Full cleanup — disconnects all events, removes Drawing objects and Highlights, stops the render loop.</p>

                <CodeBlock code={`esp:Destroy()`} />

                <h3>Integration with MonoUI</h3>
                <CodeBlock code={`local Vanity = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Vanity.luau"))()
local esp = Vanity.new()

-- In your GUI tab:
visualsTab:CreateToggle({
    text = "Box ESP",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ BoxEnabled = state })
    end
})

visualsTab:CreateToggle({
    text = "Name ESP",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ NameEnabled = state })
    end
})

visualsTab:CreateToggle({
    text = "Health ESP",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ HealthEnabled = state })
    end
})

visualsTab:CreateToggle({
    text = "Cham Highlight",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ HighlightEnabled = state })
    end
})

visualsTab:CreateSlider({
    text = "Max ESP Distance",
    min = 100,
    max = 5000,
    default = 1000,
    suffix = " studs",
    callback = function(value)
        esp:UpdateOptions({ MaxDistance = value })
    end
})`} />

                <h3>Global Cleanup</h3>
                <CodeBlock code={`getgenv().VanityCleanUp = function()
    esp:Destroy()
end`} />
              </section>
            </>
          )}

          {/* Modules: Lead Page */}
          {hash === "#/modules/lead" && (
            <>
              <section id="lead-module" className="doc-section">
                <div className="breadcrumb">
                  <span className="current">Modules</span>
                  <span className="sep">›</span>
                  <span className="current">Lead</span>
                </div>
                <div className="section-label">Module</div>
                <h2>Lead — Combat Module</h2>
                <p><strong>Lead</strong> is a flexible combat module — <strong>Aimbot</strong>, <strong>Trigger Bot</strong>, and <strong>Silent Aim</strong>. Designed for custom character models, custom health classes, and custom weapon systems. Zero external dependencies.</p>

                <div className="callout">
                  <i className="fa-solid fa-crosshairs"></i>
                  <div>Every option that targets a part, checks health, or validates players supports <strong>function callbacks</strong> — making it compatible with any game, custom NPCs, or non-standard character rigs.</div>
                </div>

                <h3>Quick Start</h3>
                <CodeBlock code={`local Lead = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Lead.luau"))()

local lead = Lead.new({
    AimEnabled = true,
    AimKey = Enum.UserInputType.MouseButton2,
    TargetPart = "Head",
    FovRadius = 120,
    Smoothness = 2.5,
    WallCheck = true,
    StickyTarget = true,

    TriggerEnabled = true,
    TriggerFovRadius = 30,
    Delay = 80,
})

lead:Start()`} />

                <h3>MonoUI Integration</h3>
                <CodeBlock code={`local Lead = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Lead.luau"))()
local lead = Lead.new()

combatTab:CreateToggle({
    text = "Aimbot",
    default = false,
    callback = function(state)
        lead:UpdateOptions({ AimEnabled = state })
    end
})

combatTab:CreateToggle({
    text = "Sticky Target",
    default = false,
    callback = function(state)
        lead:UpdateOptions({ StickyTarget = state })
    end
})

combatTab:CreateSlider({
    text = "Smoothness",
    min = 1,
    max = 20,
    default = 1,
    callback = function(value)
        lead:UpdateOptions({ Smoothness = value })
    end
})

combatTab:CreateSlider({
    text = "FOV Radius",
    min = 30,
    max = 500,
    default = 150,
    suffix = " px",
    callback = function(value)
        lead:UpdateOptions({ FovRadius = value })
    end
})

combatTab:CreateToggle({
    text = "Wall Check",
    default = false,
    callback = function(state)
        lead:UpdateOptions({ WallCheck = state })
    end
})

combatTab:CreateToggle({
    text = "Trigger Bot",
    default = false,
    callback = function(state)
        lead:UpdateOptions({ TriggerEnabled = state })
    end
})

combatTab:CreateToggle({
    text = "Silent Aim",
    default = false,
    callback = function(state)
        lead:UpdateOptions({
            SilentAim = state,
            AimKey = state and "always" or Enum.UserInputType.MouseButton2,
        })
    end
})`} />

                <h3>Custom Character Models</h3>
                <div className="callout info">
                  <i className="fa-solid fa-lightbulb"></i>
                  <div>For games with custom NPCs, monsters, or non-standard character rigs — use function lookups instead of hardcoded part names.</div>
                </div>
                <CodeBlock code={`lead:UpdateOptions({
    -- Custom target part (e.g. NPC has "Chest" not "Head")
    TargetPart = function(character)
        return character:FindFirstChild("Chest")
            or character:FindFirstChild("Head")
    end,

    -- Custom health class
    HealthClass = "MonsterHealth",

    -- Only target NPCs
    IsTargetValid = function(player, character)
        return character:FindFirstChild("IsNPC") ~= nil
    end,

    -- Custom prediction (NPCs don't always have velocity)
    PredictionFn = function(character, targetPart)
        local root = character:FindFirstChild("HumanoidRootPart")
        return targetPart.Position + (root and root.CFrame.LookVector * 4 or Vector3.zero)
    end,

    -- Custom FOV shape (e.g. rectangle)
    FovMethod = function(camPos, partPos, screenCenter, screenPos, fovRadius)
        local dx = math.abs(screenPos.X - screenCenter.X)
        local dy = math.abs(screenPos.Y - screenCenter.Y)
        return dx <= fovRadius * 1.5 and dy <= fovRadius * 0.5
    end,
})`} />

                <h3>Silent Aim</h3>
                <CodeBlock code={`lead:UpdateOptions({
    SilentAim = true,
    AimKey = "always",
    SilentAimHook = function(worldPos)
        -- Your weapon's fire function receives this world position
        -- e.g. FireRemote:FireServer(worldPos)
    end,
})`} />

                <h3>Custom Fire (Remote Weapons)</h3>
                <CodeBlock code={`lead:UpdateOptions({
    TriggerEnabled = true,
    Fire = function()
        local args = { [1] = "FireBullet", [2] = mouse.Hit.Position }
        game.ReplicatedStorage.WeaponRemote:FireServer(unpack(args))
    end,
    BeforeFire = function(player, character, targetPart)
        -- Only fire if target is close enough
        return (targetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 200
    end,
})`} />

                <h3>API Reference</h3>
                <h4><code>Lead.new(options?) → Lead</code></h4>
                <div className="params-table-wrapper">
                  <table>
                    <thead><tr><th>Option</th><th>Default</th><th>Type</th><th>Description</th></tr></thead>
                    <tbody>
                      <tr><td><code>AimEnabled</code></td><td><code>false</code></td><td>boolean</td><td>Enable aimbot</td></tr>
                      <tr><td><code>AimKey</code></td><td><code>MouseButton2</code></td><td>EnumItem / "always" / fn</td><td>Activation input</td></tr>
                      <tr><td><code>AimMethod</code></td><td><code>"Camera"</code></td><td>"Camera" / "Mouse" / fn</td><td>How aim is applied</td></tr>
                      <tr><td><code>TargetPart</code></td><td><code>"Head"</code></td><td>string / fn</td><td>Body part to target</td></tr>
                      <tr><td><code>HealthClass</code></td><td><code>"Humanoid"</code></td><td>string</td><td>Custom health class name</td></tr>
                      <tr><td><code>IsTargetValid</code></td><td><code>nil</code></td><td>fn / nil</td><td>Custom validity check</td></tr>
                      <tr><td><code>FovRadius</code></td><td><code>150</code></td><td>number</td><td>FOV circle radius (pixels)</td></tr>
                      <tr><td><code>FovMethod</code></td><td><code>nil</code></td><td>fn / nil</td><td>Custom FOV shape</td></tr>
                      <tr><td><code>Smoothness</code></td><td><code>1</code></td><td>number</td><td>Interpolation speed</td></tr>
                      <tr><td><code>StickyTarget</code></td><td><code>false</code></td><td>boolean</td><td>Lock onto same target</td></tr>
                      <tr><td><code>WallCheck</code></td><td><code>false</code></td><td>boolean</td><td>Skip behind walls</td></tr>
                      <tr><td><code>WallCheckIgnoreList</code></td><td><code>nil</code></td><td>table</td><td>Instances to ignore</td></tr>
                      <tr><td><code>MaxDistance</code></td><td><code>nil</code></td><td>number / nil</td><td>Max studs distance</td></tr>
                      <tr><td><code>PredictionFn</code></td><td><code>nil</code></td><td>fn / nil</td><td>Custom prediction</td></tr>
                      <tr><td><code>TargetOffset</code></td><td><code>nil</code></td><td>Vector3 / fn / nil</td><td>Aim offset</td></tr>
                      <tr><td><code>SilentAim</code></td><td><code>false</code></td><td>boolean</td><td>Redirect bullet silently</td></tr>
                      <tr><td><code>SilentAimHook</code></td><td><code>nil</code></td><td>fn / nil</td><td>Receive world position</td></tr>
                      <tr><td><code>TriggerEnabled</code></td><td><code>false</code></td><td>boolean</td><td>Enable trigger bot</td></tr>
                      <tr><td><code>TriggerKey</code></td><td><code>nil</code></td><td>EnumItem / fn / nil</td><td>Trigger activation</td></tr>
                      <tr><td><code>TriggerTargetPart</code></td><td><code>nil</code></td><td>string / fn / nil</td><td>Trigger target part</td></tr>
                      <tr><td><code>TriggerFovRadius</code></td><td><code>50</code></td><td>number</td><td>Trigger FOV</td></tr>
                      <tr><td><code>TriggerMaxDistance</code></td><td><code>1000</code></td><td>number</td><td>Trigger max distance</td></tr>
                      <tr><td><code>TriggerWallCheck</code></td><td><code>false</code></td><td>boolean</td><td>Wall check trigger</td></tr>
                      <tr><td><code>Delay</code></td><td><code>50</code></td><td>number</td><td>Fire rate (ms)</td></tr>
                      <tr><td><code>Fire</code></td><td><code>nil</code></td><td>fn / nil</td><td>Custom fire function</td></tr>
                      <tr><td><code>BeforeFire</code></td><td><code>nil</code></td><td>fn / nil</td><td>Pre-fire callback</td></tr>
                      <tr><td><code>AfterFire</code></td><td><code>nil</code></td><td>fn / nil</td><td>Post-fire callback</td></tr>
                    </tbody>
                  </table>
                </div>

                <h4>Methods</h4>
                <div className="params-table-wrapper">
                  <table>
                    <thead><tr><th>Method</th><th>Description</th></tr></thead>
                    <tbody>
                      <tr><td><code>:Start()</code></td><td>Start aimbot + trigger bot loops</td></tr>
                      <tr><td><code>:Stop()</code></td><td>Stop all loops</td></tr>
                      <tr><td><code>:UpdateOptions(opts)</code></td><td>Partial option update at runtime</td></tr>
                      <tr><td><code>:GetSilentAimPosition()</code></td><td>Get current silent aim world position</td></tr>
                      <tr><td><code>:Destroy()</code></td><td>Full cleanup, disconnect all</td></tr>
                    </tbody>
                  </table>
                </div>
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
