export const metadata = {
  title: 'Next.js 15 + Claude Code',
  description: 'Universal Dev Container Example',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
