import type { Metadata } from "next";
import { Lora, Merriweather } from "next/font/google";
import "./globals.css";

const lora = Lora({
  subsets: ["latin"],
  variable: "--font-lora",
  display: 'swap',
});

const merriweather = Merriweather({
  weight: ['300', '400', '700', '900'],
  subsets: ["latin"],
  variable: "--font-merriweather",
  display: 'swap',
});

export const metadata: Metadata = {
  title: "MyQueue | UNHCR Health System",
  description: "Advanced health queue management and clinical coordination for UNHCR refugee camps.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="light" suppressHydrationWarning>
      <body className={`${lora.variable} ${merriweather.variable} font-sans antialiased`} suppressHydrationWarning>
        {children}
      </body>
    </html>
  );
}
