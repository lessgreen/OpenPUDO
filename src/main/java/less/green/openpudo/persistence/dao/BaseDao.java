package less.green.openpudo.persistence.dao;

import java.io.Serializable;
import javax.persistence.EntityManager;
import javax.persistence.Query;

public abstract class BaseDao<E extends Serializable, K> {

    private final Class<E> entityClass;
    private final String keyColumnName;

    public BaseDao(Class<E> entityClass, String keyColumnName) {
        this.entityClass = entityClass;
        this.keyColumnName = keyColumnName;
    }

    protected abstract EntityManager getEntityManager();

    public void flush() {
        getEntityManager().flush();
    }

    public E get(K key) {
        return getEntityManager().find(entityClass, key);
    }

    public void persist(E ent) {
        getEntityManager().persist(ent);
    }

    public E merge(E ent) {
        return getEntityManager().merge(ent);
    }

    public int delete(K key) {
        String qs = "DELETE FROM " + entityClass.getSimpleName() + " t WHERE t." + keyColumnName + " = :key";
        Query q = getEntityManager().createQuery(qs);
        q.setParameter("key", key);
        int cnt = q.executeUpdate();
        return cnt;
    }

}
