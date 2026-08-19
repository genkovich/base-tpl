package user

import (
	"github.com/example/myapp/api/internal/modules/user/app"
	"github.com/example/myapp/api/internal/modules/user/infra"
	"github.com/example/myapp/api/internal/modules/user/ports"
	"github.com/example/myapp/api/internal/platform/database"
	"github.com/example/myapp/api/internal/platform/storage"
)

func New(db *database.DB, st storage.ObjectStorage) *ports.Handler {
	repo := infra.NewPostgresUserRepository(db)
	svc := app.NewService(repo)
	return ports.NewHandler(svc, st)
}
