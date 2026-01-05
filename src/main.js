// src/main.js - Main Vue.js application entry point

// Import Vue and Vue Router
const { createApp } = Vue;
const { createRouter, createWebHashHistory } = VueRouter;

// Import Marked.js for Markdown rendering (available globally via CDN)
// import { marked } from 'marked'; // Not needed if using CDN global access

// Define Vue Components
// Navbar Component
const Navbar = {
    template: `
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
            <div class="container">
                <router-link class="navbar-brand" to="/">
                    <img src="pages/assets/logo.png" alt="Anna AI Logo" width="30" height="30" class="d-inline-block align-text-top me-2">
                    Anna AI
                </router-link>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav ms-auto">
                        <li class="nav-item">
                            <router-link to="/overview" class="nav-link" active-class="active">Overview</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link to="/architecture" class="nav-link" active-class="active">Architecture</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link to="/cli" class="nav-link" active-class="active">CLI</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link to="/configuration" class="nav-link" active-class="active">Configuration</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link to="/troubleshooting" class="nav-link" active-class="active">Troubleshooting</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link to="/contributing" class="nav-link" active-link="active">Contribute</router-link>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    `
};

// Hero Section Component
const HeroSection = {
    template: `
        <section class="hero-section">
            <div class="container hero-content">
                <h1>Anna AI</h1>
                <p class="lead">Your Intelligent Companion for Creative and Technical Tasks, powered by Julia and Ollama.</p>
                <router-link to="/overview" class="btn btn-primary btn-lg">Get Started</router-link>
                <a href="https://github.com/am3lue/AnnaAI.jl" target="_blank" class="btn btn-outline-light btn-lg ms-2">View on GitHub</a>
            </div>
        </section>
    `
};

// Home View Component
const HomeView = {
    components: { HeroSection }, // Register HeroSection as a sub-component
    template: `
        <div>
            <HeroSection />
            <section class="container my-5">
                <h2 class="section-heading text-center">✨ Core Abilities</h2>
                <div class="row text-center">
                    <div class="col-md-4 mb-4">
                        <div class="card p-4">
                            <i class="bi bi-book feature-icon"></i>
                            <div class="card-body">
                                <h5 class="card-title">Storytelling</h5>
                                <p class="card-text">Engaging narrative generation and creative writing.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 mb-4">
                        <div class="card p-4">
                            <i class="bi bi-heart feature-icon"></i>
                            <div class="card-body">
                                <h5 class="card-title">Companionship</h5>
                                <p class="card-text">Kind, supportive, and caring interactions.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 mb-4">
                        <div class="card p-4">
                            <i class="bi bi-code-slash feature-icon"></i>
                            <div class="card-body">
                                <h5 class="card-title">Julia Helper & Debugging</h5>
                                <p class="card-text">Programming assistance, challenges, and bug resolution for Julia code.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="container my-5 docs-section">
                <h2 class="section-heading text-center">📚 Documentation & Resources</h2>
                <div class="row justify-content-center">
                    <div class="col-md-8">
                        <div class="list-group">
                            <router-link to="/overview" class="list-group-item list-group-item-action"><i class="bi bi-info-circle-fill"></i> Project Overview (README)</router-link>
                            <router-link to="/architecture" class="list-group-item list-group-item-action"><i class="bi bi-diagram-3-fill"></i> Architecture Documentation</router-link>
                            <router-link to="/cli" class="list-group-item list-group-item-action"><i class="bi bi-terminal-fill"></i> Command-Line Interface (CLI) Guide</router-link>
                            <router-link to="/configuration" class="list-group-item list-group-item-action"><i class="bi bi-gear-fill"></i> Configuration Guide</router-link>
                            <router-link to="/troubleshooting" class="list-group-item list-group-item-action"><i class="bi bi-exclamation-triangle-fill"></i> Troubleshooting Guide</router-link>
                            <router-link to="/contributing" class="list-group-item list-group-item-action"><i class="bi bi-people-fill"></i> Contribution Guidelines</router-link>
                            <a href="pages/LICENSE" target="_blank" class="list-group-item list-group-item-action"><i class="bi bi-file-earmark-text-fill"></i> License Information</a>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    `
};

// Markdown Page View Component
const MarkdownView = {
    data() {
        return {
            markdownContent: '',
            loading: true,
            error: null
        };
    },
    async created() {
        await this.loadMarkdown();
    },
    async beforeRouteUpdate(to, from, next) {
        this.loading = true;
        this.error = null;
        await this.loadMarkdown(to.path.substring(1)); // Remove leading '/'
        next();
    },
    methods: {
        async loadMarkdown(pageName = this.$route.path.substring(1)) {
            let path = `pages/${pageName}.md`;
            if (pageName === 'overview') {
                path = 'pages/README.md'; // Special case for README
            } else if (pageName === 'license') { // Special case for LICENSE, though linked via <a>
                path = 'pages/LICENSE';
            } else if (pageName === 'contributing') { // Special case for CONTRIBUTING.md
                path = 'pages/CONTRIBUTING.md';
            }

            try {
                const response = await fetch(path);
                if (!response.ok) {
                    throw new Error(`Failed to load ${path}: ${response.statusText}`);
                }
                let text = await response.text();
                if (path.endsWith('.md')) {
                    this.markdownContent = marked.parse(text);
                } else {
                    this.markdownContent = `<pre><code>${text}</code></pre>`; // Display plain text files
                }
            } catch (err) {
                console.error("Error loading markdown:", err);
                this.error = `Could not load content. ${err.message}. Please ensure '${path}' exists.`;
                this.markdownContent = '';
            } finally {
                this.loading = false;
            }
        }
    },
    template: `
        <div class="container my-5">
            <div class="markdown-body">
                <div v-if="loading" class="text-center my-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading content...</p>
                </div>
                <div v-else-if="error" class="alert alert-danger" role="alert">
                    <h4>Error!</h4>
                    <p>{{ error }}</p>
                </div>
                <div v-else v-html="markdownContent" id="markdown-content"></div>
            </div>
        </div>
    `
};

// Footer Component
const Footer = {
    template: `
        <footer class="footer mt-auto py-4">
            <div class="container">
                <p class="text-center">&copy; 2026 Anna AI Project. All rights reserved.</p>
            </div>
        </footer>
    `
};

// Define routes
const routes = [
    { path: '/', component: HomeView },
    { path: '/overview', component: MarkdownView },
    { path: '/architecture', component: MarkdownView },
    { path: '/cli', component: MarkdownView },
    { path: '/configuration', component: MarkdownView },
    { path: '/troubleshooting', component: MarkdownView },
    { path: '/contributing', component: MarkdownView },
    { path: '/license', component: MarkdownView } // Although linked via <a>, define for direct access
];

// Create router instance
const router = createRouter({
    history: createWebHashHistory(),
    routes,
    scrollBehavior(to, from, savedPosition) {
        if (savedPosition) {
            return savedPosition;
        } else {
            return { top: 0 };
        }
    }
});

// Create and mount the Vue app
const app = createApp({
    components: {
        Navbar,
        AppFooter: Footer // Renamed to AppFooter to avoid conflict with HTML <footer tag>
    },
    template: `
        <div>
            <Navbar />
            <router-view></router-view>
            <AppFooter />
        </div>
    `,
    mounted() {
        // Initial navigation based on URL hash
        if (window.location.hash === '' || window.location.hash === '#/') {
            router.replace('/');
        }
    }
});

app.use(router);
app.mount('#app');