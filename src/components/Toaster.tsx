"use client";

import { useEffect } from "react";
import { toast } from "sonner";
import { Toaster as SonnerToaster } from "@/components/ui/sonner";

export default function Toaster() {
    useEffect(() => {
        // Expose toast globally for use in vanilla JS/TS
        (window as any).toast = toast;
        (window as any).sonner = { toast };
    }, []);

    return <SonnerToaster />;
}

