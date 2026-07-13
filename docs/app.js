document.addEventListener("DOMContentLoaded", function () {
    // 1. Copy to Clipboard Functionality
    const copyButtons = document.querySelectorAll(".copy-btn");

    copyButtons.forEach(button => {
        button.addEventListener("click", function () {
            // Find code block within the same code-container
            const container = this.closest(".code-container");
            const codeBlock = container.querySelector("code");

            if (codeBlock) {
                const textToCopy = codeBlock.innerText;

                navigator.clipboard.writeText(textToCopy).then(() => {
                    // Update button UI
                    const originalText = this.innerHTML;
                    this.innerHTML = '<i class="fa-solid fa-check"></i> Copied!';
                    this.classList.add("copied");

                    setTimeout(() => {
                        this.innerHTML = originalText;
                        this.classList.remove("copied");
                    }, 2000);
                }).catch(err => {
                    console.error("Failed to copy code: ", err);
                });
            }
        });
    });

    // 2. ScrollSpy — Highlight sidebar items on scroll (Only active on index.html)
    const sections = document.querySelectorAll(".doc-section");
    const navItems = document.querySelectorAll(".nav-item");

    function scrollSpy() {
        let currentSectionId = "";

        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            if (window.scrollY >= sectionTop - 120) {
                currentSectionId = section.getAttribute("id");
            }
        });

        if (currentSectionId) {
            navItems.forEach(item => {
                item.classList.remove("active");
                const href = item.getAttribute("href") || "";
                if (href === `#${currentSectionId}` || href === `index.html#${currentSectionId}` || href.endsWith(`#${currentSectionId}`)) {
                    item.classList.add("active");
                }
            });
        }
    }

    const isLandingPage = window.location.pathname.endsWith("index.html") || window.location.pathname.endsWith("/") || !window.location.pathname.includes(".html");
    if (isLandingPage && sections.length > 0) {
        window.addEventListener("scroll", scrollSpy);
        scrollSpy();
    }

    // 3. Global Document Search & Dropdown Overlay
    const searchInput = document.getElementById("doc-search");
    let searchData = [];
    let selectedIndex = -1;

    // Create search dropdown container if it doesn't exist
    let searchResults = document.getElementById("search-results-dropdown");
    if (!searchResults && searchInput) {
        searchResults = document.createElement("div");
        searchResults.id = "search-results-dropdown";
        searchResults.className = "search-results";
        searchInput.parentNode.appendChild(searchResults);
    }

    // Static pages search data
    const staticPages = [
        {
            name: "Introduction",
            url: "index.html#introduction",
            group: "Getting Started",
            icon: "fa-circle-info",
            description: "Overview of MonoUI premium, modular Roblox UI library."
        },
        {
            name: "Quick Start",
            url: "index.html#getting-started",
            group: "Getting Started",
            icon: "fa-rocket",
            description: "Bootstrap loadstring and start executing MonoUI."
        },
        {
            name: "Features",
            url: "index.html#features",
            group: "Getting Started",
            icon: "fa-star",
            description: "List of primitive features and configuration saving."
        },
        {
            name: "Full Script",
            url: "FullScript.html",
            group: "Examples",
            icon: "fa-code",
            description: "A complete working example using all major MonoUI features."
        }
    ];

    // Fetch documentation data
    fetch("dump.json")
        .then(response => response.json())
        .then(data => {
            searchData = [...staticPages];
            // Format dynamic API functions
            for (const [funcName, funcData] of Object.entries(data)) {
                let icon = "fa-cube";
                if (funcData.type === "core") {
                    if (funcName === "CreateWindow") icon = "fa-window-maximize";
                    else if (funcName === "Notify") icon = "fa-bell";
                    else if (funcName === "SetWatermark") icon = "fa-chart-line";
                    else if (funcName === "CreateControlHUD") icon = "fa-sliders";
                    else if (funcName === "AddCleanup") icon = "fa-trash-can";
                    else if (funcName === "CreateTimer") icon = "fa-clock";
                } else if (funcData.type === "layout") {
                    if (funcName === "CreateSection") icon = "fa-grip-lines";
                    else if (funcName === "CreateTab") icon = "fa-folder-open";
                    else if (funcName === "CreateHBar") icon = "fa-grip";
                    else if (funcName === "CreateVBar") icon = "fa-ellipsis-vertical";
                } else if (funcData.type === "components") {
                    if (funcName === "CreateButton") icon = "fa-square-check";
                    else if (funcName === "CreateColorPicker") icon = "fa-palette";
                    else if (funcName === "CreateDropdown") icon = "fa-caret-down";
                    else if (funcName === "CreateInput") icon = "fa-keyboard";
                    else if (funcName === "CreateKeybind") icon = "fa-keyboard";
                    else if (funcName === "CreateLogger") icon = "fa-terminal";
                    else if (funcName === "CreatePlayerList") icon = "fa-users";
                    else if (funcName === "CreateSlider") icon = "fa-sliders";
                    else if (funcName === "CreateTargetBody") icon = "fa-child";
                    else if (funcName === "CreateToggle") icon = "fa-toggle-on";
                    else if (funcName === "CreateParagraph") icon = "fa-paragraph";
                    else if (funcName === "CreateDivider") icon = "fa-minus";
                }

                searchData.push({
                    name: funcName,
                    url: `${funcName}.html`,
                    group: funcData.label,
                    icon: icon,
                    description: funcData.description
                });
            }
        })
        .catch(err => {
            console.warn("Failed to load search index dump.json: ", err);
            searchData = [...staticPages];
        });

    function renderResults(results) {
        if (!searchResults) return;
        searchResults.innerHTML = "";
        selectedIndex = -1;

        if (results.length === 0) {
            searchResults.innerHTML = '<div class="search-no-results">No results found</div>';
            searchResults.classList.add("active");
            return;
        }

        results.forEach((item, index) => {
            const resultItem = document.createElement("a");
            resultItem.href = item.url;
            resultItem.className = "search-result-item";
            resultItem.dataset.index = index;

            resultItem.innerHTML = `
                <div class="search-result-header">
                    <span class="search-result-title">
                        <i class="fa-solid ${item.icon}"></i>
                        <span>${item.name}</span>
                    </span>
                    <span class="search-result-group">${item.group}</span>
                </div>
                <div class="search-result-desc">${item.description}</div>
            `;

            resultItem.addEventListener("click", function (e) {
                if (item.url.startsWith("index.html#") && isLandingPage) {
                    e.preventDefault();
                    const hash = item.url.split("#")[1];
                    const targetEl = document.getElementById(hash);
                    if (targetEl) {
                        targetEl.scrollIntoView({ behavior: "smooth" });
                        window.location.hash = hash;
                        searchResults.classList.remove("active");
                        searchInput.value = "";
                    }
                }
            });

            searchResults.appendChild(resultItem);
        });

        searchResults.classList.add("active");
    }

    if (searchInput) {
        searchInput.addEventListener("input", function () {
            const query = this.value.toLowerCase().trim();

            if (query === "") {
                if (searchResults) {
                    searchResults.classList.remove("active");
                    searchResults.innerHTML = "";
                }
                return;
            }

            const filtered = searchData.filter(item => {
                return item.name.toLowerCase().includes(query) ||
                    item.description.toLowerCase().includes(query) ||
                    item.group.toLowerCase().includes(query);
            });

            renderResults(filtered.slice(0, 8));
        });

        // Keyboard navigation
        searchInput.addEventListener("keydown", function (e) {
            if (!searchResults) return;
            const items = searchResults.querySelectorAll(".search-result-item");
            if (items.length === 0) return;

            if (e.key === "ArrowDown") {
                e.preventDefault();
                selectedIndex = (selectedIndex + 1) % items.length;
                updateSelection(items);
            } else if (e.key === "ArrowUp") {
                e.preventDefault();
                selectedIndex = (selectedIndex - 1 + items.length) % items.length;
                updateSelection(items);
            } else if (e.key === "Enter") {
                e.preventDefault();
                if (selectedIndex >= 0 && selectedIndex < items.length) {
                    items[selectedIndex].click();
                    if (!items[selectedIndex].href.includes("#") || !isLandingPage) {
                        window.location.href = items[selectedIndex].href;
                    }
                }
            } else if (e.key === "Escape") {
                searchResults.classList.remove("active");
                this.blur();
            }
        });
    }

    function updateSelection(items) {
        items.forEach(item => item.classList.remove("selected"));
        if (selectedIndex >= 0 && selectedIndex < items.length) {
            items[selectedIndex].classList.add("selected");
            items[selectedIndex].scrollIntoView({ block: "nearest" });
        }
    }

    // Close on click outside
    document.addEventListener("click", function (e) {
        if (searchInput && searchResults && !searchInput.contains(e.target) && !searchResults.contains(e.target)) {
            searchResults.classList.remove("active");
        }
    });

    // 4. Fetch Latest Version from GitHub Release
    const versionBadge = document.querySelector(".navbar .badge");
    if (versionBadge) {
        fetch("https://api.github.com/repos/BloodLetters/Mono-UI/releases/latest")
            .then(response => {
                if (response.ok) {
                    return response.json();
                }
                throw new Error("Network response was not ok");
            })
            .then(data => {
                if (data && data.tag_name) {
                    versionBadge.innerText = data.tag_name;
                }
            })
            .catch(err => {
                console.warn("Failed to fetch latest version from GitHub: ", err);
            });
    }
});
