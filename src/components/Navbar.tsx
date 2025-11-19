"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { AuroraText } from "@/components/ui/aurora-text";
import { NavbarDropdownUser } from "@/components/navbar/navbar-dropdown-user";
import { Menu, X, Moon, Sun } from "lucide-react";

const pages = [
    { name: "Home", href: "/" },
    { name: "Mercat", href: "/mercado" },
    { name: "About", href: "/about" }
];

interface User {
    id: string;
    email?: string;
    name: string;
    avatar?: string | null;
}

export default function Navbar() {
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);
    const [darkMode, setDarkMode] = useState(false);
    const [balance, setBalance] = useState<number | null>(null);

    useEffect(() => {
        // Check for saved theme preference or default to system preference
        const savedTheme = localStorage.getItem("theme");
        const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
        const isDark = savedTheme === "dark" || (!savedTheme && prefersDark);

        setDarkMode(isDark);
        if (isDark) {
            document.documentElement.classList.add("dark");
        } else {
            document.documentElement.classList.remove("dark");
        }
    }, []);

    useEffect(() => {
        const checkAuth = async () => {
            try {
                const response = await fetch("/api/auth/me");
                const data = await response.json();
                setUser(data.user);

                // Load balance if user is authenticated
                if (data.user) {
                    loadBalance();
                } else {
                    setBalance(null);
                }
            } catch (error) {
                console.error("Error checking auth:", error);
                setUser(null);
                setBalance(null);
            } finally {
                setLoading(false);
            }
        };

        checkAuth();

        // Refresh auth state when page becomes visible (e.g., after redirect from OAuth)
        const handleVisibilityChange = () => {
            if (!document.hidden) {
                checkAuth();
            }
        };

        document.addEventListener("visibilitychange", handleVisibilityChange);
        window.addEventListener("focus", checkAuth);

        return () => {
            document.removeEventListener("visibilitychange", handleVisibilityChange);
            window.removeEventListener("focus", checkAuth);
        };
    }, []);

    const loadBalance = async () => {
        try {
            const response = await fetch("/api/user-profile/balance");
            const data = await response.json();
            if (data.success && data.balance !== undefined) {
                setBalance(data.balance);
            }
        } catch (error) {
            console.error("Error loading balance:", error);
        }
    };

    // Refresh balance when user changes
    useEffect(() => {
        if (user) {
            loadBalance();
        } else {
            setBalance(null);
        }
    }, [user]);

    // Listen for balance updates (e.g., after purchase)
    useEffect(() => {
        const handleBalanceUpdate = () => {
            if (user) {
                loadBalance();
            }
        };

        window.addEventListener('balanceUpdated', handleBalanceUpdate);
        return () => {
            window.removeEventListener('balanceUpdated', handleBalanceUpdate);
        };
    }, [user]);

    const handleGoogleLogin = async () => {
        const form = document.createElement("form");
        form.method = "POST";
        form.action = "/api/auth/signin";

        const providerInput = document.createElement("input");
        providerInput.type = "hidden";
        providerInput.name = "provider";
        providerInput.value = "google";

        form.appendChild(providerInput);
        document.body.appendChild(form);
        form.submit();
    };

    const toggleDarkMode = () => {
        const newDarkMode = !darkMode;
        setDarkMode(newDarkMode);

        if (newDarkMode) {
            document.documentElement.classList.add("dark");
            localStorage.setItem("theme", "dark");
        } else {
            document.documentElement.classList.remove("dark");
            localStorage.setItem("theme", "light");
        }
    };

    return (
        <nav className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex justify-between items-center h-16">
                    {/* Logo */}
                    <div className="flex-shrink-0">
                        <AuroraText className="text-xl sm:text-2xl font-bold font-[LaligaFont]">
                            Fantasy Big Three
                        </AuroraText>
                    </div>

                    {/* Desktop Navigation */}
                    <div className="hidden md:flex md:items-center md:gap-6 md:flex-1 md:justify-center">
                        {pages.map((page) => (
                            <a
                                href={page.href}
                                key={page.name}
                                className="text-xl font-medium font-[LaligaFont] text-foreground/70 hover:text-foreground transition-colors px-3 py-2 rounded-md hover:bg-accent"
                            >
                                {page.name}
                            </a>
                        ))}
                    </div>

                    {/* Desktop User Menu */}
                    <div className="hidden md:flex md:items-center md:gap-4">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={toggleDarkMode}
                            aria-label="Toggle dark mode"
                            className="h-9 w-9"
                        >
                            {darkMode ? (
                                <Sun className="h-5 w-5" />
                            ) : (
                                <Moon className="h-5 w-5" />
                            )}
                        </Button>
                        {loading ? (
                            <div className="h-9 w-24 animate-pulse bg-muted rounded-md" />
                        ) : user ? (
                            <NavbarDropdownUser
                                name={user.name}
                                email={user.email}
                                avatar={user.avatar}
                                balance={balance}
                            />
                        ) : (
                            <Button
                                onClick={handleGoogleLogin}
                                variant="outline"
                                className="gap-2"
                            >
                                <svg className="h-4 w-4" viewBox="0 0 24 24">
                                    <path
                                        fill="currentColor"
                                        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                                    />
                                    <path
                                        fill="currentColor"
                                        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                                    />
                                    <path
                                        fill="currentColor"
                                        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                                    />
                                    <path
                                        fill="currentColor"
                                        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                                    />
                                </svg>
                                <span className="hidden sm:inline">Login amb Google</span>
                                <span className="sm:hidden">Google</span>
                            </Button>
                        )}
                    </div>

                    {/* Mobile Menu Button */}
                    <div className="md:hidden flex items-center gap-2">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={toggleDarkMode}
                            aria-label="Toggle dark mode"
                            className="h-9 w-9"
                        >
                            {darkMode ? (
                                <Sun className="h-5 w-5" />
                            ) : (
                                <Moon className="h-5 w-5" />
                            )}
                        </Button>
                        {loading ? (
                            <div className="h-8 w-20 animate-pulse bg-muted rounded-md" />
                        ) : user ? (
                            <NavbarDropdownUser
                                name={user.name}
                                email={user.email}
                                avatar={user.avatar}
                                balance={balance}
                            />
                        ) : (
                            <Button
                                onClick={handleGoogleLogin}
                                variant="outline"
                                size="sm"
                                className="gap-2"
                            >
                                <svg className="h-4 w-4" viewBox="0 0 24 24">
                                    <path
                                        fill="currentColor"
                                        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                                    />
                                    <path
                                        fill="currentColor"
                                        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                                    />
                                    <path
                                        fill="currentColor"
                                        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                                    />
                                    <path
                                        fill="currentColor"
                                        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                                    />
                                </svg>
                                <span>Google</span>
                            </Button>
                        )}
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                            aria-label="Toggle menu"
                        >
                            {mobileMenuOpen ? (
                                <X className="h-6 w-6" />
                            ) : (
                                <Menu className="h-6 w-6" />
                            )}
                        </Button>
                    </div>
                </div>

                {/* Mobile Navigation */}
                {mobileMenuOpen && (
                    <div className="md:hidden border-t">
                        <div className="px-2 pt-2 pb-3 space-y-1">
                            {pages.map((page) => (
                                <a
                                    href={page.href}
                                    key={page.name}
                                    className="block px-3 py-2 text-base font-medium text-foreground/70 hover:text-foreground hover:bg-accent rounded-md transition-colors"
                                    onClick={() => setMobileMenuOpen(false)}
                                >
                                    {page.name}
                                </a>
                            ))}
                        </div>
                    </div>
                )}
            </div>
        </nav>
    );
}