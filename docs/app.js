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

    // 2. ScrollSpy — Highlight sidebar items on scroll
    const sections = document.querySelectorAll(".doc-section");
    const navItems = document.querySelectorAll(".nav-item");
    const container = document.querySelector(".content-container");

    function scrollSpy() {
        let currentSectionId = "";

        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            // Highlight when section is near the top of the viewport
            if (window.scrollY >= sectionTop - 120) {
                currentSectionId = section.getAttribute("id");
            }
        });

        if (currentSectionId) {
            navItems.forEach(item => {
                item.classList.remove("active");
                if (item.getAttribute("href") === `#${currentSectionId}`) {
                    item.classList.add("active");
                }
            });
        }
    }

    window.addEventListener("scroll", scrollSpy);
    // Initial run on load
    scrollSpy();

    // 3. Live Document Search & Filter
    const searchInput = document.getElementById("doc-search");

    searchInput.addEventListener("input", function () {
        const query = this.value.toLowerCase().trim();

        sections.forEach(section => {
            const heading = section.querySelector("h1, h2");
            const headingText = heading ? heading.innerText.toLowerCase() : "";
            const contentText = section.innerText.toLowerCase();
            const sectionId = section.getAttribute("id");

            // Check if matches heading, content text or ID
            const isMatch = headingText.includes(query) || contentText.includes(query) || sectionId.includes(query);

            if (query === "" || isMatch) {
                section.style.display = "block";
                // Show matching sidebar item
                const sidebarItem = document.querySelector(`.nav-item[href="#${sectionId}"]`);
                if (sidebarItem) sidebarItem.style.display = "flex";
            } else {
                section.style.display = "none";
                // Hide non-matching sidebar item
                const sidebarItem = document.querySelector(`.nav-item[href="#${sectionId}"]`);
                if (sidebarItem) sidebarItem.style.display = "none";
            }
        });

        // Adjust display groups: if all items in a nav group are hidden, hide the group header
        const navGroups = document.querySelectorAll(".nav-group");
        navGroups.forEach(group => {
            const visibleItems = group.querySelectorAll(".nav-item[style='display: flex;'], .nav-item:not([style])");
            const title = group.querySelector(".group-title");
            if (visibleItems.length === 0) {
                if (title) title.style.display = "none";
            } else {
                if (title) title.style.display = "block";
            }
        });
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
