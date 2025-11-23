package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type User struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

var users = []User{
	{ID: 1, Name: "Alice"},
	{ID: 2, Name: "Bob"},
}

func main() {
	r := gin.Default()

	// Root endpoint
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Go + Gin + Claude Code",
			"status":  "✅ Running",
			"features": []string{
				"Go 1.21",
				"Gin web framework",
				"Fast compilation",
				"Native concurrency",
				"Claude Code ready",
			},
		})
	})

	// Get all users
	r.GET("/api/users", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"users": users,
		})
	})

	// Get user by ID
	r.GET("/api/users/:id", func(c *gin.Context) {
		id := c.Param("id")
		c.JSON(http.StatusOK, gin.H{
			"id": id,
			"message": "User details",
		})
	})

	// Create user
	r.POST("/api/users", func(c *gin.Context) {
		var newUser User
		if err := c.BindJSON(&newUser); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		newUser.ID = len(users) + 1
		users = append(users, newUser)
		c.JSON(http.StatusCreated, newUser)
	})

	println("🚀 Server running on http://localhost:8080")
	println("✅ Claude Code is ready to help!")
	r.Run(":8080")
}
